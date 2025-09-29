#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SOURCE_DIR=$1
DEST_DIR=$2
DAYS=${3:-14} # if not provided considered as 14 days


LOGS_FOLDER="/var/log/shell-script"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
# LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" 
LOG_FILE="$LOGS_FOLDER/backup.log" # modified to run the script as command

USERID=$(id -u)

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE



if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privelege"
    exit 1 # failure is other than 0
fi

USAGE(){
    echo -e "$R USAGE:: sudo sh 24-backup.sh <SOURCE_DIR> <DEST_DIR> <DAYS>[optional, default 14 days] $N"
    exit 1
}

### check source dir and dest dir pass or not
if [ $# -lt 2 ]; then
    USAGE
fi

## source dir exists or not
if [ ! -d "$SOURCE_DIR" ]; then
   echo -e "$R Source $SOURCE_DIR does not exist $N"
   exit 1
fi

## DEST dir exists or not
if [ ! -d "$DEST_DIR" ]; then
   echo -e "$R Destination $DEST_DIR does not exist $N"
   exit 1
fi


## FIND the Files
FILES=$(find "$SOURCE_DIR" -name "*.log" -type f -mtime +"$DAYS")

if [ -n "$FILES" ]; then
    echo "Files Found"
    TIMESTAMP=$(date +%F-%H-%M)
    ZIP_FILE_NAME="$DEST_DIR/app-logs-$TIMESTAMP.zip"
    zip -r "$ZIP_FILE_NAME" $FILES
    echo "Archived to $ZIP_FILE_NAME"
 
 ## Check archieve success
  if [ -f $ZIP_FILE_NAME ]
then
echo -e "Archieve .... $G SUCCESS $N"

while IFS= read -r filepath
do
  echo "Deleting the file: $filepath"
  rm -rf $filepath
  echo "Deleted the file: $filepath"
done <<< $FILES_TO_DELETE

else
    echo -e "Archieve .... $R FAILURE $N"
    exit 1
fi
else
  echo -e "No Files to archieve .... $Y SKIPPING $N"
fi



