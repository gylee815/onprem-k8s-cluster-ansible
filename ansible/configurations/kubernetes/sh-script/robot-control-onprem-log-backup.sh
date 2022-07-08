#!/bin/bash

# export INSTANCEID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
# export HOSTIP=$(echo $HOSTNAME | awk -F "." '{print$1}')

export YESTERDAY=$(date "+%Y-%m-%d" --date="-1 day")
export Y_YEAR=$(echo $YESTERDAY | awk -F "-" '{print $1}')
export Y_MONTH=$(echo $YESTERDAY | awk -F "-" '{print $2}')
export Y_DAY=$(echo $YESTERDAY | awk -F "-" '{print $3}')

export THREE_DAY_BEFORE=$(date "+%Y-%m-%d" --date="-3 day")
export SEVEN_DAY_BEFORE=$(date "+%Y-%m-%d" --date="-7 day")

export THIRTY_DAY_BEFORE=$(date "+%Y\/%m\/%d" --date="-30 day")

export BASE_LOG_DIR=/mnt/k8s/lge-robot
export BASE_LOG_BACKUP_DIR=/root/lge-robot-log-backup

sudo find $BASE_LOG_DIR -type d -exec chmod 755  {} +
sudo find $BASE_LOG_DIR -type f -exec chmod 644 {} +

array=()
while IFS=  read -r -d $'\n'; do
    array+=("$REPLY")
done < <(find $BASE_LOG_DIR -maxdepth 1 -type d | awk -F "/" '{print $5}')
# done < <(sudo find /mnt/lge-robot/ -name "*.log*" | awk -F "/" '{print $6}' )

echo "--- log backup to hdd and s3 : $(date) ---"

for service in "${array[@]}"; do
        echo $service
        export service=$service
        export cur_log_dir

        if [[ "$service" = "map" ]]
        then
            export MAP_LOG_BACKUP_DIR=$BASE_LOG_BACKUP_DIR/map/$Y_YEAR/$Y_MONTH/$Y_DAY
            cur_log_dir=$BASE_LOG_DIR/map
            
            # gzip and backup 1 day before log file to hdd
            mkdir -p $MAP_LOG_BACKUP_DIR
            find $cur_log_dir -name "*.log*" -type f -daystart -mtime 1 -exec sh -c 'LOGFILE=$(echo {} |  cut -d"/" -f7); gzip -c {} > $MAP_LOG_BACKUP_DIR/$LOGFILE.gz' \;

        elif [[ "$service" = "be" ]]
        then
            array_pods=()
            while IFS=  read -r -d $'\n'; do
                    array_pods+=("$REPLY")
            done < <(find $BASE_LOG_DIR/$service/*logs/* -maxdepth 0 -type d | awk -F "/" '{print $7}')
            # done < <(sudo find /var/lib/docker/volumes/$customer-robot-mss-logs/_data/* -maxdepth 0 -type d | awk -F "/" '{print $8}')

            cur_log_dir=$BASE_LOG_DIR/be

            for pod in "${array_pods[@]}"; do
                echo $pod
                export pod=$pod
                POD_PATH=$BASE_LOG_DIR/$service/*logs/$pod
                export BE_APP_LOG_BACKUP_DIR=$BASE_LOG_BACKUP_DIR/be/application-logs/$Y_YEAR/$Y_MONTH/$Y_DAY
                
                # gzip and backup 1 day before log file to hdd
                mkdir -p $BE_APP_LOG_BACKUP_DIR
                find $POD_PATH -name "*.log.$YESTERDAY-*" -type f -exec sh -c 'LOGFILE=$(echo {} |  cut -d"/" -f9); gzip -c {} > $BE_APP_LOG_BACKUP_DIR/$pod.$LOGFILE.gz' \;

                # # cp 1 day before splited logs by size to s3
                # find $CONTAINER_PATH -name "application_internal.log.$YESTERDAY-*" -exec sh -c 'LOGFILE=$(echo {} |  cut -d"/" -f10); aws s3 cp --no-progress "{}" s3://$customer-robot-mss-$STAGE-logs/application/internal/$Y_YEAR/$Y_MONTH/$Y_DAY/$INSTANCEID.$HOSTIP.$container.$LOGFILE' \;
                # find $CONTAINER_PATH -name "application.log.$YESTERDAY-*" -exec sh -c 'LOGFILE=$(echo {} |  cut -d"/" -f10); aws s3 cp --no-progress "{}" s3://$customer-robot-mss-$STAGE-logs/application/external/$Y_YEAR/$Y_MONTH/$Y_DAY/$INSTANCEID.$HOSTIP.$container.$LOGFILE' \;
            done
        else
            echo "None"
        fi

        # delete 7 day before log files 
        find $cur_log_dir -name "*.log*"  -type f -daystart -mtime 7 -exec sh -c 'rm -rf {}' \;

done

# delete empty directory on BASE_LOG_DIR path
echo "--- delete empty log dir ---"
find $BASE_LOG_DIR -depth -type d -empty -exec sh -c 'echo {}; rm -rf {}' \;

# delete 30 days before backup log dir
echo "-- delete old backup log dir($THIRTY_DAY_BEFORE) ---"
find $BASE_LOG_BACKUP_DIR -regex "\/.*\/$THIRTY_DAY_BEFORE" -type d -exec sh -c 'rm -rf {}' \;