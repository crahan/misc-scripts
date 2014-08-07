#!/bin/sh
# try to pull in a new quote from quotedb.com
newquote=`curl -s http://www.quotedb.com/quote/quote.php?action=random_quote`

# did it succeed?
if [ $? -eq 0 ]; then
    # ok, curl was able to pull in a new quote. Parse and cache it
    echo $newquote | sed "s/^document.write('\(.*\)<br>.*<a.*>\(.*\)<\/a.*;$/\"\1\" - \2/" > ~/.qotd
fi

cat ~/.qotd
