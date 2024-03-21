#! /bin/bash
set -euo pipefail

env

# Check environment
if [ -n "${GET_REMOTE_HOST}" ]; then
  echo "GET_REMOTE_HOST script was supplied evaluating, and overriding REMOTE_HOST variable" 
  REMOTE_HOST=$(eval ${GET_REMOTE_HOST})
fi

if [ -z "${REMOTE_HOST}" ]; then
  echo "REMOTE_HOST was not set"
fi

if [ -z "${REMOTE_USER}" ]; then
  echo "REMOTE_USER was not set"
fi

if [ -z "${REMOTE_PASSWORD}" ]; then
  echo "REMOTE_PASSWORD was not set"
fi

LOCAL_PORT=8080
# REMOTE_HOST CAN include username and password like 'username:password@ip:port'
# REMOTE_USER and REMOTE_PASSWORD shall be override.

for HOST_AND_PORT in $(echo $REMOTE_HOST| sed "s/,/ /g")
do
  if [ -z "${HOST_AND_PORT}" ]; then
    continue
  fi

  if echo "$HOST_AND_PORT" | grep -q "@"; then
  	USERNAME_AND_PASSWORD=$(echo "$HOST_AND_PORT" | awk -F'@' '{print $1}')
  	USERNAME=$(echo "$USERNAME_AND_PASSWORD" | cut -d':' -f1)
  	PASSWORD=$(echo "$USERNAME_AND_PASSWORD" | cut -d':' -f2)
  	HOST_AND_PORT=$(echo "$HOST_AND_PORT" | awk -F'@' '{print $NF}')
  else
  	USERNAME=$REMOTE_USER
  	PASSWORD=$REMOTE_PASSWORD
  	HOST_AND_PORT="$HOST_AND_PORT"
  fi
  
  # Extracting host and port
  HOST=$(echo "$HOST_AND_PORT" | cut -d':' -f1)
  PORT=$(echo "$HOST_AND_PORT" | cut -d':' -f2)
  
  proxy-login-automator \
    -local_port $LOCAL_PORT \
    -local_host 0.0.0.0 \
    -remote_host $HOST \
    -remote_port $PORT \
    -usr $USERNAME -pwd $PASSWORD\
    -is_remote_https $REMOTE_HTTPS \
    -ignore_https_cert $IGNORE_CERT &

  LOCAL_PORT=$((LOCAL_PORT + 1))
done

wait
