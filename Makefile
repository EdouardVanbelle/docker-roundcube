DOCKER=roundcube
LOCAL=/data-active
INSTANCE="${DOCKER}-instance"

all: build

.PHONY: build container start stop enter

# build image
build:
	docker build -t dropz-one/${DOCKER} .

#create container
container: 
	docker run -t -d -h ${DOCKER} --name "${INSTANCE}" -p 80:80 -p 443:443 -v ${LOCAL}/mail-data:/data dropz-one/${DOCKER}

start:
	docker start ${INSTANCE}
stop:
	docker stop ${INSTANCE}

enter:
	docker exec -t -i ${INSTANCE} /bin/bash


