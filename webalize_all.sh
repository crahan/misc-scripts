mkdir -p webalizer/$1
dots=$((`echo $1|sed 's/[^\.]//g'|wc -m`-1))
total=`expr $dots + 3`

for f in `ls $1/access.log.* | sort -r -t . -nk $total`
do
    webalizer -n $1 -p -o webalizer/$1 $f
done
