#!/bin/sh

docker container export roundcube-instance | tar -xO home/roundcube/plugins/managesieve/config.inc.php > conf/managesieve.config.inc.php.LIVE
