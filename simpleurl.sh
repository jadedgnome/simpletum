#!/bin/bash

basehost="$1"
tag="$2"
wget="wget -nv"
apikey=$(cat api.key)
offset=0
mkdir -p -- "$basehost"

while :
do
    apiurl=$($wget -O - "http://api.tumblr.com/v2/blog/$basehost/posts?api_key=$apikey&offset=$offset&tag=$tag")
    grep -q ',"posts":\[{' <<<"$apiurl" || break

    ./json.sh <<<"$apiurl" | 
    grep -e '"original_size","url"]' -e ',"body"]' | 
    sed 's.\\..g' | 
    grep -Eo 'http://[^" ]+(gif|jpeg|jpg|png)' |
    sort -u |
    $wget -P "$basehost" -c -i - 
    offset=$((offset+20))
done
