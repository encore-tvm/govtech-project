#!/bin/bash

# Error monitoring of apache log file
#Author : Sunil John
#Date : 21-Mar-2021

logfile=$1

if [ $# -ne 1 ] ; then
        echo "Pls input log filename!!"
        exit 1
fi

if [ !  -f $logfile ] ; then
        echo "File $1 does not exists!!"
        exit 1
fi


# Check error count every 1 hour
updated_lines=`wc -l $logfile | awk '{print $1}'`
last_total_lines=$updated_lines

#Counts the number of HTTP 4xx and 5xx response statuses in the apache log file
while true
do
        error_count=`tail -$updated_lines $logfile | grep -c 'HTTP/[0-9].[0-9]" [4-5][0-9][0-9]'`

        echo $error_count

        # Send email alert if error exceeds 100
        if [ $error_count -gt 100 ]; then
                echo "Error count more than 100 , Send email"
                echo "Error thershold alert" | mailx -s "Error thershold alert" encore_tvm@yahoo.com
        fi

        # run in cron job hourly if cronjob is enabled and avoid sleep
        # and store the values in temp files instead of variable
        echo "Press <CTRL+C> to exit., Sleep for 1 hour"
        sleep 3600

        # change the pointer to the last reading lines
        total_line_count=`wc -l $logfile | awk '{print $1}'`
        updated_lines=`expr $total_line_count - $last_total_lines`
        last_total_lines=$total_line_count

        echo "Total Line count: $total_line_count , Updated lines $updated_lines, last_total_lines: $total_line_count"

done
