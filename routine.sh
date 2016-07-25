#!/bin/bash
slackcli -h general -m "Starting Backup"
cd /tmp
file=$(date +%Y%m%d%H%M%S).sql
mysqldump \
  --host ${MYSQL_HOST} \
  --port ${MYSQL_PORT} \
  -u ${MYSQL_USER} \
  --password="${MYSQL_PASS}" \
  ${MYSQL_DB} > ${file}
if [ "${?}" -eq 0 ]; then
  gzip ${file}
  s3cmd put ${file}.gz s3://${S3_BUCKET}/${file}.gz
  rm ${file}.gz
  slackcli -h general -m "Backup Succesfull"
else
  slackcli -h general -m "Ooops, Today problem to backup"
  echo "Error backing up mysql"
  exit 255
fi

