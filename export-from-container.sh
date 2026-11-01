#!/bin/sh

echo diff are located in
docker inspect -f '{{.GraphDriver.Data.UpperDir}}' mail-roundcube

exit

docker container export mail-roundcube | tar -xO home/roundcube/config/config.inc.php > conf/config.inc.php.LIVE
