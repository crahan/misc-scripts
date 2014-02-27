#!/bin/sh
#
# Dumps and gzips a set databases
#

# Check for required tools
if ! which mysqldump > /dev/null; then
    echo "Could not find mysqldump."
    exit 1
fi

if ! which gzip > /dev/null; then
    echo "Could not find gzip."
    exit 1
fi

# Check parameters
while getopts ":u:" options; do
    case $options in
        u ) user=$OPTARG;;
       \? ) echo "Invalid option: -$OPTARG" >&2
            exit 1;;
    esac
done

# Set default user if none specified
user=${user:-root}

# Dump databases
if [ -p /dev/fd/0 ]; then # check if stdin is a pipe
    dblist=()
    while read data; do
       dblist=( "${dblist[@]}" "$data" )
    done

    if [ ${#dblist[@]} -gt 0 ]; then
        exec 0< /dev/tty # redirect TTY back to stdin (replacing the earlier pipe)
        read -s -p "Password for $user: " password
        echo ""
        for dbname in "${dblist[@]}"; do
            echo "Dumping $dbname"
            fname="`date +%Y%m%d`_${dbname}_db.sql"
            mysqldump -u $user -p$password $dbname > $fname
            gzip $fname
        done
    else
        echo "No databases specified."
    fi
else
    echo "No databases specified."
fi

