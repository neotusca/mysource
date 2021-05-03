#!/bin/sh
export LANG=c
TODAY=`date +%Y%m%d`

##### system config file copy ######
/bin/cp -p /etc/passwd /svc/backup/conf
/bin/cp -p /etc/group /svc/backup/conf
/bin/cp -p /etc/iptables/iptables.conf /svc/backup/conf
/bin/cp -p /etc/hosts /svc/backup/conf
/bin/cp -p /etc/hosts.allow /svc/backup/conf
/bin/cp -p /etc/rc.local /svc/backup/conf
/usr/bin/crontab -l -u root > /svc/backup/conf/crontab.root

##### http config file copy ######
cp -pur /conf /svc/backup/conf/httpd_conf


##### mysql config file copy ######
cp -apr /etc/my.cnf /svc/backup/conf


##### conf directory compress  ######
/bin/tar cvfzp /backup/kms-medialog.conf_$TODAY.tar.gz /svc/backup/conf
#/bin/tar cvfzp /backup/kms-medialog.src_$TODAY.tar.gz /svc/redmine --exclude="*.tar.gz" --exclude="*.tar" 
/bin/tar cvfzp /backup/kms-medialog.src_$TODAY.tar.gz /svc/redmine --exclude="*.tar.gz" --exclude="*.tar" \
                                                                   --exclude="/svc/redmine/mysql/data" \
                                                                   --exclude=/svc/redmine/apps/redmine/htdocs/files \
                                                                   --exclude=/svc/redmine/apps/redmine_tmp/htdocs/files
