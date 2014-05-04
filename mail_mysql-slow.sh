#!/bin/sh
# Mail the slow query log if it contains any entries
if grep '#' /var/log/mysql/mysql-slow.log > /dev/null; then 
	mail -s "MySQL slow query log" foo.bar@example.com < /var/log/mysql/mysql-slow.log; 
fi
