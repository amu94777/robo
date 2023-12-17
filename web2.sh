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

echo "*****web configuration****"


dnf install nginx -y &>> $LOGFILE

systemctl enable nginx 
VALIDATE $? "enabled nginx"

systemctl start nginx
VALIDATE $? "STARTED NGINX"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "REMOVED DEFAULT CODE"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE

cd /usr/share/nginx/html

unzip /tmp/web.zip &>> $LOGFILE
VALIDATE $? "UNZIPPED CONTENT"

cp /home/centos/robo/roboshop.conf /etc/nginx/default.d/roboshop.conf
VALIDATE $? "COPIED ROBOSHOP CONF"

systemctl restart nginx 
VALIDATE $? "RESTARTED NGINX"


