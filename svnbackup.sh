#!/bin/sh

SVN_DIR="/path/to/svn/repos"
BACKUP_DIR="/path/to/backup/location/"
SVN_REPOS=`ls $SVN_DIR`
EMAIL="foo@bar.com"
STATUS=0
MESSAGE="Subversion backup result\n===================="

# check if mount succeeded
if [ -f /backup/subversion/.available ]; then

	# iterate over all the available repositories
	for repos in $SVN_REPOS; do
		/usr/bin/svn-hot-backup --archive-type=gz --num-backups=7 $SVN_DIR/$repos $BACKUP_DIR

		if [ $? -eq 0 ]; then
			STATUS=$(($STATUS+$?))
			MESSAGE=$MESSAGE"\n$repos: OK"
		else
			STATUS=$(($STATUS+$?))
			MESSAGE=$MESSAGE"\n$repos: FAILED"
		fi
	done

	# send out status email	
	if [ $STATUS -eq 0 ]; then
		echo -e $MESSAGE | mail -s "SVN Backup [Successful]" $EMAIL
	else
		echo -e $MESSAGE | mail -s "SVN Backup [Errors]" $EMAIL
	fi

# looks like we couldn't mount the backup share
else
	echo -e $MESSAGE"\nBackup share not mounted." | mail -s "SVN Backup [Failed]" $EMAIL
fi
