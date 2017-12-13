import time
import ssl
import ConfigParser
import argparse
import logging
from requests import Request, Session
from BeautifulSoup import BeautifulSoup
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.poolmanager import PoolManager

__author__ = 'erickleao.dnt'

FORMAT = '%(asctime)-15s %(levelname)s: %(message)s'
logging.basicConfig(level=logging.INFO, format=FORMAT)
logger = logging.getLogger('sonicwall-logon')
logger.info('SonicWall Logon Started')


class SSLAdapter(HTTPAdapter):
    """An HTTPS Transport Adapter that uses an arbitrary SSL version."""

    def __init__(self, ssl_version=None, **kwargs):
        self.ssl_version = ssl_version
        super(SSLAdapter, self).__init__(**kwargs)

    def init_poolmanager(self, connections, maxsize, block=False):
        self.poolmanager = PoolManager(num_pools=connections,
                                       maxsize=maxsize,
                                       block=block,
                                       ssl_version=ssl.PROTOCOL_TLSv1)


class AuthenticationError(Exception):
    pass


class SonicWallLogon(object):
    URLs = {
        'params': 'auth1.html',
        'auth': 'auth.cgi',
        'confirm': 'dynUserLogin.html',
        'status_top': 'loginStatusTop.html',
        'status': 'dynLoginStatus.html?1stLoad=yes'
    }
    AUTH_ERROR_INTERVAL = 60

    def __init__(self, username, password, server_ip, server_port, login_duration):
        self.username = username
        self.password = password
        self.login_duration = login_duration
        self.server_host = 'https://%s:%s/' % (server_ip, server_port)
        self.server_port = server_port
        self.auth_interval = (self.login_duration - 10) * 60

        self.session = Session()
        # self.session.mount('https://', SSLAdapter())

    def request(self, url, method='GET', params=None, body=None, headers={}, cookies={}):
        request = Request(
            method, url,
            params=params,
            data=body,
            headers=headers,
            cookies=cookies
        )
        prepped = request.prepare()
        return self.session.send(prepped, timeout=5, verify=False)

    def get_params(self):
        r = self.request(self.server_host + self.URLs.get('params'))
        if r.status_code != 200:
            raise AuthenticationError('Impossible to get auth params from SonicWall server.')
        document = BeautifulSoup(r.text)
        params = {
            'param1': document.find('input', {'name': 'param1'})['value'],
            'param2': document.find('input', {'name': 'param2'})['value'],
            'id': document.find('input', {'name': 'id'})['value'],
            'sessId': document.find('input', {'name': 'sessId'})['value'],
            'select2': 'English'
        }
        return params

    def auth(self):
        auth_params = self.get_params()
        auth_params.update({
            'uName': self.username,
            'pass': self.password,
            'digest': ''
        })

        r = self.request(
            self.server_host + self.URLs.get('auth'),
            method='POST',
            params=None,
            body=auth_params,
            headers={'Content-Type': 'application/x-www-form-urlencoded'}
        )
        if r.status_code != 200:
            raise AuthenticationError('Received auth error from SonicWall server.')
        self.auth_confirm(auth_params)
        logger.info('Login performed.')

    def auth_confirm(self, auth_params):
        host = self.server_host.replace(':%s' % self.server_port, ':1080')
        host = host.replace('https', 'http')
        cookies = {'SessId': auth_params.get('SessId')}
        self.request(host + self.URLs.get('confirm'), cookies=cookies)
        self.request(host + self.URLs.get('status_top'), cookies=cookies)
        self.request(host + self.URLs.get('status'), cookies=cookies)

    def auto_auth(self):
        while True:
            try:
                interval = self.auth_interval
                self.auth()
            except Exception as e:
                logger.error(e)
                interval = self.AUTH_ERROR_INTERVAL
            finally:
                time.sleep(interval)


parser = argparse.ArgumentParser(description='SonicWall auto logon.')
parser.add_argument(
    '-c', '--config', help='Config file', required=True,
    default='/etc/sonicwall-logon/auth.conf', type=str
)
args = parser.parse_args()
config = ConfigParser.ConfigParser()
config.readfp(open(args.config))

sonicwall_logon = SonicWallLogon(
    config.get('Auth Credentials', 'username'),
    config.get('Auth Credentials', 'password'),
    config.get('Server Info', 'host'),
    config.get('Server Info', 'port'),
    config.getint('Server Info', 'login_duration')
)
# Blocks forever
sonicwall_logon.auto_auth()

# Make service start with OS
# sudo update-rc.d sonicwall-logon defaults
