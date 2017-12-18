#!/bin/bash

PROCESS_NAME="sonicwall-logon"
PROCESS_BASE_PATH="/opt/"$PROCESS_NAME"/"
PROCESS_LOG="/var/log/"$PROCESS_NAME".log"
CONFIG_FILE_PATH="/etc/"$PROCESS_NAME"/auth.conf"

PYTHON_ENV="$HOME/venv-sonicwall"
if [ ! -d "$PYTHON_ENV" ]; then
    if [ ! -f "/usr/bin/virtualenv" ]; then
        sudo apt-get install -yq virtualenv
    fi
    virtualenv -p /usr/bin/python3 $PYTHON_ENV
fi
source $PYTHON_ENV/bin/activate

python -u $PROCESS_BASE_PATH"auto_logon.py" -c $CONFIG_FILE_PATH
