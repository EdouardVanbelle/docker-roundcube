FROM debian:jessie

MAINTAINER Edouard Vanbelle <edouard@vanbelle.fr>

RUN \
	apt-get update \
    	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	    nginx php5-fpm nano wget sqlite3 procps \
	    php5-mcrypt php5-intl php5-sqlite php-pear \
	    php-net-smtp php-mail-mime \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /root

# when roundcube grows older, change version in the download link, but also in the 'mv' command
RUN \
    wget --no-check-certificate https://downloads.sourceforge.net/project/roundcubemail/roundcubemail/1.1.3/roundcubemail-1.1.3-complete.tar.gz -O - | tar xz && \
    rm -fr /usr/share/nginx/www && \
    mv /root/roundcubemail-1.1.3 /usr/share/nginx/www && \
    rm -fr /usr/share/nginx/www/installer && \
    mkdir -p /data/logs/roundcube && \
    mkdir -p /data/cache/roundcube 


ADD config.inc.php /usr/share/nginx/www/config/
ADD nginx.conf     /etc/nginx/sites-enabled/default
ADD start.sh       /start.sh

VOLUME /data

EXPOSE 80 443

CMD [ "bash", "/start.sh" ]
