#!/bin/bash

basehost=$(echo "$1" | cut -d '/' -f3| sed -e 's|http://||Ig' -e 's|/||Ig' -e 's|tagged||Ig')
tag=$(echo "$2" | cut -d '/' -f 5)
wget="wget -q"
apikey=$(cat api.key)
offset=0

while :
do
	apiurl=$($wget -O - "http://api.tumblr.com/v2/blog/$basehost/posts?api_key=$apikey&offset=$offset&tag=$tag")
	grep -q ',"posts":\[{' <<<"$apiurl" || break
	./json.sh <<<"$apiurl" | 
	grep -e '"original_size","url"]' -e ',"body"]' | 
	sed 's.\\..g' | 
	grep -Eo 'http://[^" ]+(gif|jpeg|jpg|png)' |
	sort -u >> "$basehost.txt"; 
	offset=$((offset+20))
	clear 
	echo "[+] Writing URL's to $basehost.txt"
done
