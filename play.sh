#!/bin/sh
echo "<pre>LD_LIBRARY_PATH: $LD_LIBRARY_PATH</pre>"
export LD_LIBRARY_PATH=/am7x/:/am7x/lib/

echo "Content-type: text/html"
echo ""

# Debug: print the raw QUERY_STRING
echo "<pre>QUERY_STRING: $QUERY_STRING</pre>"

# Determine URL: either from command-line or QUERY_STRING
if [ -n "$1" ]; then
    URL="$1"
elif [ -n "$QUERY_STRING" ]; then
    URL=$(echo "$QUERY_STRING" | sed -n 's/.*url=\([^&]*\).*/\1/p')
    # URL-decode function
    urldecode() {
        local url_encoded="${1//+/ }"
        printf '%b' "${url_encoded//%/\\x}"
    }
    URL=$(urldecode "$URL")
else
    echo "<pre>Usage: $0 <URL></pre>"
    exit 1
fi

# Debug: print the final URL
echo "<pre>Decoded URL: $URL</pre>"

# Call your existing cast script
#export LD_LIBRARY_PATH=/am7x/lib/libcurl.so.4
/root/cast.sh "$URL" "127.0.0.1"

echo "<html><body>Playing: $URL<br><a href='/index.html'>Back</a></body></html>"
