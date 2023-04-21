#!/bin/bash

# Write a shell script to detect stack drift for all stacks present in your aws account. Schedule this script in cron to get list of drifted stack daily at 10:00am. Output should be in csv file with this name `DD-MM-YYYY_CF_DRIFT_LIST.csv`
# Headers for CSV File can be: StackName,StackStatus,CreatedTime,DriftStatus,RegionName
# Script Execution on EC2 Instance
# bash detect_drift_script.sh us-east-1
# bash detect_drift_script.sh ap-south-1

# Output CSV File
# StackName,StackStatus,CreatedTime,DriftStatus
# 03-s3-stack,CREATE_COMPLETE,2021-12-02,DRFITED
# 12-s3-stack,CREATE_COMPLETE,2021-12-04,DRFITED
# 34-s3-stack,CREATE_COMPLETE,2021-12-11,DRFITED

REGION_NAME=$1
# Dynamically Get the value of current date and time
DATE_VALUE=`date +%d-%m-%Y-%H-%M-%S`
STACK_STATUS_FILTER="CREATE_COMPLETE"
OUTPUT_CSV_FILENAME="${DATE_VALUE}_CF_DRIFT_LIST_${REGION_NAME}.csv"
echo "OUTPUT_CSV_FILENAME is $OUTPUT_CSV_FILENAME"
CSV_HEADER_ROW="StackName,StackStatus,CreatedTime,DriftStatus"
echo $CSV_HEADER_ROW >> $OUTPUT_CSV_FILENAME
for STACK_NAME in $(aws cloudformation list-stacks --region $REGION_NAME --stack-status-filter $STACK_STATUS_FILTER --query StackSummaries[*].[StackName] --output text);
    do
        echo "STACK_NAME value : $STACK_NAME"
        CREATED_TIME=$(aws cloudformation describe-stacks --region $REGION_NAME --stack-name $STACK_NAME --query Stacks[0].[CreationTime] --output text)
        DRIFT_DETECTION_ID=$(aws cloudformation detect-stack-drift --region $REGION_NAME --stack-name $STACK_NAME --query StackDriftDetectionId --output text)
        echo "DRIFT_DETECTION_ID value is $DRIFT_DETECTION_ID"
        sleep 10
        STACK_DRIFT_STATUS=$(aws cloudformation describe-stack-drift-detection-status --region $REGION_NAME --stack-drift-detection-id $DRIFT_DETECTION_ID --query StackDriftStatus --output text)
        echo "STACK_DRIFT_STATUS is $STACK_DRIFT_STATUS"
        if [ $STACK_DRIFT_STATUS == "DRIFTED" ]; then
            Stack_Name=$stack_name
            Drift_Status=$STACK_DRIFT_STATUS
            echo "$STACK_NAME,$STACK_STATUS_FILTER,$CREATED_TIME,$STACK_DRIFT_STATUS"
            echo "$STACK_NAME,$STACK_STATUS_FILTER,$CREATED_TIME,$STACK_DRIFT_STATUS" >> $OUTPUT_CSV_FILENAME
        fi
    done

# Enhancements
# Specify an S3 Bucket Name and add AWS S3 Copy Command to upload the CSV File into a output bucket
# Use aws sns cli command to send an email containing the S3 Bucket URL file Path.
# Schedule this using crontab in linux