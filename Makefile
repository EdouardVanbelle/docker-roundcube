DOCKER=roundcube
LOCAL=/data-active
INSTANCE="${DOCKER}-instance"
LISTEN=`dig +short A mail.vanbelle.fr`
TIMEZONE=`readlink /etc/localtime | sed 's!/usr/share/zoneinfo/!!'`

all: build

.PHONY: build container start stop enter

# build image
build:
	docker build --pull -t dropz-one/${DOCKER} .

move:
	docker container rename ${INSTANCE} ${INSTANCE}.old

#create container
container: 
	docker run -t -d -h ${DOCKER} --restart=unless-stopped --env TZ=${TIMEZONE} --name "${INSTANCE}" -p ${LISTEN}:80:80 -p ${LISTEN}:443:443 -v ${LOCAL}/mail-data:/data dropz-one/${DOCKER}
	docker network connect web-net ${INSTANCE}

start:
	docker start ${INSTANCE}
stop:
	docker stop ${INSTANCE}

# clean only moved container
clean:
	docker container rm ${INSTANCE}.old

enter:
	docker exec -t -i ${INSTANCE} /bin/bash

