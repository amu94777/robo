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

echo "****cart configuration****"

dnf module disable nodejs -y

dnf module enable nodejs:18 -y

dnf install nodejs -y

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "ROBOSHOP USER CREATION"
else
    echo "ROBOSHOP USER IS ALREADY CREATED:::$G SKIPPILG $N"
fi

mkdir -p /app
VALIDATE $? "APP DIRECTORY CREATION IS"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "COPIED APPLICATION DATA"

cd /app 

unzip -o /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "UNZIPFILE CONTENT"

cd /app 

npm install &>> $LOGFILE
VALIDATE $? "NPM INSTALLED"

 cp /home/centos/robo/cart.service /etc/systemd/system/cart.service

 systemctl daemon-reload

 systemctl enable cart 

 systemctl start cart