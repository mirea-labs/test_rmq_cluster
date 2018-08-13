#!/bin/sh
#sendemail -f rabbit@123.ru -u "["`hostname -s`"] "$3 -m ` date +"%Y-%m-%d %H:%M:%S"` -t esb@123.ru -s 192.168.166.14 >> /dev/null