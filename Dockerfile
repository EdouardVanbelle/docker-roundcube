FROM debian:bookworm

MAINTAINER Edouard Vanbelle <edouard@vanbelle.fr>


# php-net-idna2 no more availabvle in bullseye 
RUN \
	echo "LANG=C" > /etc/default/locale \
	&& apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get upgrade -q -y \
    	&& DEBIAN_FRONTEND=noninteractive apt-get install -q -y --no-install-recommends \
	    apt-utils nginx vim wget sqlite3 procps zip unzip cron curl \
	    php8.2-fpm php8.2-common php8.2-zip php8.2-intl php8.2-sqlite3 php-pear composer \
	    php-net-smtp php-mail-mime php-net-socket php-net-sieve php-auth-sasl php-gnupg php-ldap php-gd \
            ca-certificates openssl \
	&& apt-get clean \
	&& apt-get autoclean \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /root

ENV ROUNDCUBE_VERSION=1.6.2
# After a new version upgraded please run: su -s /bin/bash www-data -c "cd /home/roundcube; ./bin/update.sh"


RUN \
    groupadd -g 5001 roundcube && \
    useradd -g roundcube -u 5001 roundcube -d /home/roundcube -M && \
    wget -q https://github.com/roundcube/roundcubemail/releases/download/${ROUNDCUBE_VERSION}/roundcubemail-${ROUNDCUBE_VERSION}-complete.tar.gz -O - | tar -xz && \
    mv /root/roundcubemail-${ROUNDCUBE_VERSION} /home/roundcube && \
    rm -fr /home/roundcube/installer && \
    chown -R roundcube: /home/roundcube && \ 
    mkdir -p /data/logs/roundcube && \
    mkdir -p /data/cache/roundcube && \
    mv -f /home/roundcube/composer.json-dist  /home/roundcube/composer.json && \
    rm -f /etc/nginx/sites-enabled/default && \
    su roundcube -c "cd /home/roundcube; rm -rf vendor; rm -f composer.lock; /usr/bin/composer clear-cache" && \
    if [ -e /home/roundcube/composer.lock ]; then su roundcube -c "cd /home/roundcube; /usr/bin/composer update --no-dev"; else su roundcube -c "cd /home/roundcube; /usr/bin/composer install --no-dev"; fi  && \
    touch /etc/in-docker

ADD conf/nginx.sites-enabled	     	     /etc/nginx/sites-enabled
ADD conf/nginx.conf		     	     /etc/nginx/conf.d
# TODO: could configure php-fpm roundcube pool
ADD conf/phpfpm-roundcube-conf.ini	     /etc/php/8.2/fpm/conf.d/80-roundcube.ini

ADD conf/managesieve.config.inc.php 	     /home/roundcube/plugins/managesieve/config.inc.php
ADD conf/newmail_notifier.config.inc.php     /home/roundcube/plugins/newmail_notifier/config.inc.php
ADD conf/zipdownload.config.inc.php	     /home/roundcube/plugins/zipdownload/config.inc.php
ADD conf/emoticons-config.inc.php	     /home/roundcube/plugins/emoticons/config.inc.php

ADD conf/config.inc.php 		     /home/roundcube/config/config.inc.php

ADD conf/roundcube.cron			     /etc/cron.d/roundcube

ADD scripts/manage       		     /usr/local/bin/manage

VOLUME /data

EXPOSE 80

# FIXME: implement it @see: https://dzone.com/articles/health-checking-your-docker-containers
HEALTHCHECK --interval=30s --timeout=3s CMD curl --silent --show-error --fail --user-agent "healthcheck" --connect-to "mail.vanbelle.fr:80:127.0.0.1:80" http://mail.vanbelle.fr/ -o /dev/null || exit 1

ENTRYPOINT [ "/usr/local/bin/manage", "_run" ]
