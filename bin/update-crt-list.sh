#!/bin/sh
set -e
changed=no
list=
txt=/etc/letsencrypt/crt-list.txt
echo Updating $txt

touch $txt
mkdir -p /etc/letsencrypt/live
cd /etc/letsencrypt/live
for domain in "$(ls)"; do
    cd "$domain"
    if [ -f fullchain.pem -a -f privkey.pem ]; then
        # Check if something has changed
        old=
        [ -f combined.pem ] && old="$(cat combined.pem)"
        current="$(cat fullchain.pem privkey.pem)"
        if [ "$old" != "$current" ]; then
            # Store new combined cert
            echo "$current" > combined.pem
            changed=yes
        fi
        list="$list$(pwd)/combined.pem\n"
    fi
    cd ..
done

# Check if domains list or any cert has changed
if [ "$list" != "$(cat $txt)" -o $changed == yes ]; then
    # Update list and reload server
    echo -e "$list" > $txt
    reload.sh
fi
