#!/bin/bash

set -eux

# make sure the dirs are there

mkdir -p /data/cache/roundcube
mkdir -p /data/log/roundcube

if [ ! -e /data/config/ssl/default.pem ]
then
	echo please provide in data:/config/ssl/default.pem + default.key
	exit 1
fi

chown -R www-data: /data/cache/roundcube /data/log/roundcube

HASH=$(cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 48 | head -n 1) 
sed -i "s/{{RANDOM_KEY}}/${HASH}/g" /home/roundcube/config/config.inc.php


service nginx    start
service php5-fpm start


tail -F  /data/log/roundcube/*

