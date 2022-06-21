#!/bin/bash

HOSTNAME=ip-or-domain
USERNAME=admin
PASSWORD=passpass
DATABASE=db_name
PORT=35432


echo "Pulling Database: This may take a few minutes"
export PGPASSWORD="$PASSWORD"
pg_dump -F t -h $HOSTNAME -p $PORT -U $USERNAME --no-owner --no-acl $DATABASE > $(date +%Y-%m-%d).backup
unset PGPASSWORD
gzip $(date +%Y-%m-%d).backup
echo "Pull Complete"

echo "Clearing old backups"
find . -type f -iname '*.backup.gz' -ctime +15 -not -name '????-??-01.backup.gz' -delete
echo "Clearing Complete"
