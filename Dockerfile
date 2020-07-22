FROM debian:buster

MAINTAINER Edouard Vanbelle <edouard@vanbelle.fr>

RUN \
	echo "LANG=C" > /etc/default/locale \
	&& apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get upgrade -q -y \
    	&& DEBIAN_FRONTEND=noninteractive apt-get install -q -y --no-install-recommends \
	    apt-utils nginx vim wget sqlite3 procps zip cron \
	    php-fpm php7.3-common php-zip php-intl php7.3-sqlite php-pear composer \
	    php-net-smtp php-mail-mime php-net-socket php-net-idna2 php-net-sieve php-auth-sasl php-gnupg php-ldap php-gd \
            ca-certificates openssl \
	&& apt-get clean \
	&& apt-get autoclean \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /root

    #wget -q https://downloads.sourceforge.net/project/roundcubemail/roundcubemail/1.1.3/roundcubemail-1.1.3-complete.tar.gz -O - | tar -xz && \
# when roundcube grows older, change version in the download link, but also in the 'mv' command
RUN \
    groupadd -g 5001 roundcube && \
    useradd -g roundcube -u 5001 roundcube -d /home/roundcube -M && \
    wget -q https://github.com/roundcube/roundcubemail/releases/download/1.4.4/roundcubemail-1.4.4-complete.tar.gz -O - | tar -xz && \
    mv /root/roundcubemail-1.4.4 /home/roundcube && \
    rm -fr /home/roundcube/installer && \
    chown -R roundcube: /home/roundcube && \ 
    mkdir -p /data/logs/roundcube && \
    mkdir -p /data/cache/roundcube && \
    mv -f /home/roundcube/composer.json-dist  /home/roundcube/composer.json && \
    if [ -e /home/roundcube/composer.lock ]; then su roundcube -c "cd /home/roundcube; /usr/bin/composer update --no-dev"; else su roundcube -c "cd /home/roundcube; /usr/bin/composer install --no-dev"; fi  && \
    touch /etc/in-docker

ADD conf/nginx.sites-enabled	     	     /etc/nginx/sites-enabled
ADD conf/nginx.conf		     	     /etc/nginx/conf.d
# TODO: could configure php-fpm roundcube pool
ADD conf/phpfpm-roundcube-conf.ini	     /etc/php/7.3/fpm/conf.d/80-roundcube.ini

ADD conf/managesieve.config.inc.php 	     /home/roundcube/plugins/managesieve/config.inc.php
ADD conf/newmail_notifier.config.inc.php     /home/roundcube/plugins/newmail_notifier/config.inc.php
ADD conf/zipdownload.config.inc.php	     /home/roundcube/plugins/zipdownload/config.inc.php
ADD conf/emoticons-config.inc.php	     /home/roundcube/plugins/emoticons/config.inc.php

ADD conf/config.inc.php 		     /home/roundcube/config/config.inc.php

ADD conf/roundcube.cron			     /etc/cron.d/roundcube

ADD scripts/manage       		     /usr/local/bin/manage

VOLUME /data

EXPOSE 80 443

ENTRYPOINT [ "/usr/local/bin/manage", "_run" ]
