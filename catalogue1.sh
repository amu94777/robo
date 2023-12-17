#!/bin/bash
ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
VALIDATE(){
 if [ $1 -ne 0 ] 
 then
    echo -e "$R ERROR ::::::$2 FAILED $N"
    exit 1
 else
    echo -e "$G $2 is successfull $N"
fi         
}
if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:::you are not a root user $N"
    exit 1
else
    echo -e "$G you are a root user $N"
fi

echo "****CATALOGUE CONFIGURATION*****"

dnf module disable nodejs -y &>> $LOGFILE

dnf module enable nodejs:18 -y &>> $LOGFILE

dnf install nodejs -y &>> $LOGFILE

id roboshop

if [ $? -ne 0 ]
then 
    useradd roboshop
    VALIDATE $? "ADDED USER"
else
    echo "ROBOSHOPUSER IS ALREADY THERE" 
 fi      

mkdir -p /app
VALIDATE $? "APP DIRECTORY CREATION"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

cd /app 

unzip -o /tmp/catalogue.zip &>> $LOGFILE
cd /app

npm install &>> $LOGFILE
VALIDATE $? "NPM INSTALLED"

cp /home/centos/robo/catalogue.service /etc/systemd/system/catalogue.service

systemctl daemon-reload

systemctl start catalogue

cp /home/centos/robo/mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-org-shell -y

mongo --host MONGODB-SERVER-IPADDRESS </app/schema/catalogue.js



