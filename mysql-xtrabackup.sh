#!/bin/sh

source /etc/profile

PWD='/svc/backup'
cd $PWD
HOSTNAME=`hostname -s`

NOW_DATE=`date +%Y%m%d_%H`
OLD_DATE=`date -d "1 day ago" +%Y%m%d_%H`
DEL_DATE=`date -d "1 day ago" +%Y%m%d_%H`
BACKUP_LOG_DIR=$PWD/innobackup_time.txt
BACKUP_LOCATED=$PWD/innobackup

## old date backup delete
rm -rf ${BACKUP_LOCATED}/${DEL_DATE}
#rm -rf ${BACKUP_LOCATED}/mvno-db_${OLD_DATE}.tar.gz

mkdir -p ${BACKUP_LOCATED}/${NOW_DATE}
chown -R mysql:mysql ${BACKUP_LOCATED}/${NOW_DATE}

echo "#################################################################" >> ${BACKUP_LOG_DIR}

###########################################################################
echo "xtrabackup start : "`date` >> ${BACKUP_LOG_DIR}

/usr/bin/innobackupex \
    --host=127.0.0.1 \
    --user=root \
    --password='medialog' \
    --ibbackup=xtrabackup \
    --no-lock \
    --no-timestamp \
    ${BACKUP_LOCATED}/${NOW_DATE} \
    1> $PWD/logs/innobackupex_${NOW_DATE}.err 2> $PWD/logs/innobackupex_${NOW_DATE}.log

echo "xtrabackup end : "`date` >> ${BACKUP_LOG_DIR}
###########################################################################
## Full backup error check ##
backup_success_check=`/usr/bin/tail --lines=1 /svc/backup/logs/innobackupex_${NOW_DATE}.log |grep "completed"|awk '{print $3}'`

if [ x${backup_success_check} = "x" ]
then
  rm -rf ${BACKUP_LOCATED}/${NOW_DATE}
  echo "-------------------" >> ${BACKUP_LOG_DIR}
  echo "backup fail stop ${NOW_DATE}" >> ${BACKUP_LOG_DIR}
  echo "-------------------" >> ${BACKUP_LOG_DIR}
  exit;
fi

###########################################################################
echo "apply backup start : "`date` >> ${BACKUP_LOG_DIR}

/usr/bin/innobackupex \
    --apply-log \
    ${BACKUP_LOCATED}/${NOW_DATE} \
    1> $PWD/logs/innobackupex_apply_${NOW_DATE}.err 2> $PWD/logs/innobackupex_apply_${NOW_DATE}.log

echo "apply backup end : "`date` >> ${BACKUP_LOG_DIR}
###########################################################################
echo "tar compress start : "`date` >> ${BACKUP_LOG_DIR}

BACKUP_FILE1=${BACKUP_LOCATED}/${NOW_DATE}
BACKUP_FILE2=/svc/backup/logs/innobackupex_${NOW_DATE}.err
BACKUP_FILE3=/svc/backup/logs/innobackupex_apply_${NOW_DATE}.err

cp /etc/my.cnf ${BACKUP_LOCATED}/${NOW_DATE}/mvno-my.cnf

cd ${BACKUP_LOCATED}
/bin/tar cvfz ${HOSTNAME}_${NOW_DATE}.tar.gz ${BACKUP_FILE1} ${BACKUP_FILE2} ${BACKUP_FILE3}
#rm -rf ${BACKUP_LOCATED}/${DEL_DATE}

#cp -rp ${BACKUP_LOCATED}/${HOSTNAME}_${NOW_DATE}.tar.gz ${NFS_BACKUP_LOCATED}

rm -rf ${BACKUP_LOCATED}/${HOSTNAME}_${OLD_DATE}.tar.gz

echo "tar compress end : "`date` >> ${BACKUP_LOG_DIR}
###########################################################################

#echo "############## FTP backup start ###################" >> ${BACKUP_LOG_DIR}
#echo `date` >> ${BACKUP_LOG_DIR}

#/usr/bin/ftp -ivn 192.168.141.146 << END
#user webadmin \$#common2017H146
#bin
#pass
#cd /Database/privacy-db
#lcd ${BACKUP_LOCATED}
#put privacy-db_${NOW_DATE}.tar.gz
#quit
#END

#echo `date` >> ${BACKUP_LOG_DIR}
#echo "############## FTP backup stop ###################" >> ${BACKUP_LOG_DIR}
###########################################################################
