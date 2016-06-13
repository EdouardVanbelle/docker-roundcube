FROM debian:jessie

MAINTAINER Edouard Vanbelle <edouard@vanbelle.fr>

RUN \
	apt-get update \
    	&& DEBIAN_FRONTEND=noninteractive apt-get install -y -q --no-install-recommends \
	    nginx php5-fpm nano wget sqlite3 procps \
	    php5-mcrypt php5-intl php5-sqlite php-pear \
	    php-net-smtp php-mail-mime \
            ca-certificates openssl \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /root

# when roundcube grows older, change version in the download link, but also in the 'mv' command
    #groupadd -g 5000 roundcube && \
    #useradd -g roundcube -u 5000 roundcube -d /home/roundcube -M && \
RUN \
    wget -q https://downloads.sourceforge.net/project/roundcubemail/roundcubemail/1.1.3/roundcubemail-1.1.3-complete.tar.gz -O - | tar -xz && \
    mv /root/roundcubemail-1.1.3 /home/roundcube && \
    rm -fr /home/roundcube/installer && \
    chown -R root: /home/roundcube && \ 
    mkdir -p /data/logs/roundcube && \
    mkdir -p /data/cache/roundcube && \
    touch /etc/in-docker

ADD conf/nginx.conf     		     /etc/nginx/sites-enabled/default
# TODO: could configure php-fpm roundcube pool
ADD conf/managesieve.config.inc.php 	     /home/roundcube/plugins/managesieve/config.inc.php
ADD conf/newmail_notifier.config.inc.php     /home/roundcube/plugins/newmail_notifier/config.inc.php
ADD conf/zipdownload.config.inc.php	     /home/roundcube/plugins/zipdownload/config.inc.php
ADD conf/phpfpm-roundcube-conf.ini	     /etc/php5/fpm/conf.d/80-roundcube.ini
ADD plugins/message_label/		     /home/roundcube/plugins/message_label/

ADD conf/config.inc.php 		     /home/roundcube/config/config.inc.php

ADD scripts/manage       		     /usr/local/bin/manage

VOLUME /data

EXPOSE 80 443

ENTRYPOINT [ "/usr/local/bin/manage", "_run" ]
