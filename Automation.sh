#!/bin/bash

timestamp=$(date '+%d%m%Y-%H%M%S')
myname="Aishwarya"
s3_bucket="upgrad-aishwarya"

# Updating required packages
sudo apt update -y

# Installing Apache2
if echo dpkg --get-selections | grep -q "apache2"
    then
        echo "Apache2 is already installed";
    else
        sudo apt install apache2 -y
        echo "Apache2 is installed";
fi

# Starting Apache2
if systemctl is-active apache2
    then
        echo "Apache2 is already running";
    else
        sudo systemctl start apache2
        echo "Apache2 is started";
fi

# Enabling Apache2
if systemctl is-enabled apache2
    then
        echo "Apache2 is already enabled";
    else
        sudo systemctl enable apache2
        echo "Apache2 is enabled";
fi

# Archiving web server logs and moving to /tmp folder
echo "Archiving web server logs and moving those to /tmp folder"
tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log

# Pushing Web server logs to S3 Bucket
echo "Pushing web server logs to S3 bucket"
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar