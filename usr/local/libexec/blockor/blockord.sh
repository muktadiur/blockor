#!/bin/sh
#
# Copyright (c) 2022-2022, Muktadiur Rahman <muktadiur@gmail.com>
# All rights reserved.

. /usr/local/etc/blockor.conf

OS=$(uname -s | tr '[A-Z]' '[a-z]')

tail -n 0 -f $auth_file | while read line
do 
	echo $line | grep -E "$search_pattern" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' >> $blockor_file

	for white_ip in $(echo $blockor_whitelist); do
		if [ $OS = 'openbsd' ]; then
            sed -i '/'"${white_ip}"'$/d' $blockor_file
        else
            sed -i '' '/'"${white_ip}"'$/d' $blockor_file
        fi
	done

	cat $blockor_file | sort | uniq -c | sort -nr | while read row
	do
		count=$(echo $row | awk '{print $1}')
		ip=$(echo $row | awk '{print $2}')
		if [ $count -ge $max_tolerance ]; then
			pfctl -t blockor -q -T add $ip
			echo $(date -u): $ip 'added in blocked IP list.' >> $blockor_log_file
		fi
	done
done
