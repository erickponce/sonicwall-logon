#!/bin/bash

PROCESS_NAME="sonicwall-logon"
PROCESS_BASE_PATH="/opt/"$PROCESS_NAME"/"
PROCESS_LOG="/var/log/"$PROCESS_NAME".log"
CONFIG_FILE_PATH="/etc/"$PROCESS_NAME"/auth.conf"
python -u $PROCESS_BASE_PATH"auto_logon.py" -c $CONFIG_FILE_PATH