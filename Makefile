DOCKER=roundcube

all: build

.PHONY: build run

build:
	docker build -t dropz-one/${DOCKER} .

run: 
	docker run -t -i -h roundcube -p 80:80 -p 443:443 -v /home/mail-data:/data dropz-one/${DOCKER}

