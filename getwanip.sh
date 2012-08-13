#!/bin/bash
ext_ip=`/usr/bin/curl --silent http://checkip.dyndns.org | awk '{printf $6}' | cut -f 1 -d "<" | tr -d 'n'`
echo $ext_ip 

