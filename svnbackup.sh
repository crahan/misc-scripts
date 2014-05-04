#!/bin/sh

SVN_DIR="/opt/svn"
BACKUP_SHARE="/mnt/backups"
BACKUP_DIR="$BACKUP_SHARE/subversion/"
SVN_REPOS=`ls $SVN_DIR`
EMAIL="someone@example.com"
STATUS=0
MESSAGE="Subversion backup result\n===================="

# mount backup share
mount $BACKUP_SHARE

# check if mount succeeded
if [ -f $BACKUP_SHARE/.available ]; then

    # iterate over all the available repositories
    for repos in $SVN_REPOS; do
        if [ $repos != "conf" ]; then
            /bin/hot-backup.py --archive-type=gz --num-backups=7 $SVN_DIR/$repos $BACKUP_DIR
			
            if [ $? -eq 0 ]; then
                STATUS=$(($STATUS+$?))
                MESSAGE=$MESSAGE"\n$repos: OK"
            else
                STATUS=$(($STATUS+$?))
                MESSAGE=$MESSAGE"\n$repos: FAILED"
            fi
        fi
    done

    # send out status email	
    if [ $STATUS -eq 0 ]; then
        echo -e $MESSAGE | mail -s "SVN Backup [Successful]" $EMAIL
    else
        echo -e $MESSAGE | mail -s "SVN Backup [Errors]" $EMAIL
    fi

    # unmount backup share
    umount $BACKUP_SHARE

# looks like we couldn't mount the backup share
else
    echo -e $MESSAGE"\nCould not mount backup share." | mail -s "SVN Backup [Failed]" $EMAIL
fi

