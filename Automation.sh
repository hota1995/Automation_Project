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

# Checking Inventory File. Creating one (if not available)
if [ -f /var/www/html/inventory.html ]
    then
        echo "Inventory file already exists"
    else
        touch /var/www/html/inventory.html
        echo "<b>Log Type &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Time Created &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Type &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Size</b>" >> /var/www/html/inventory.html
        echo "Invenroy file is created"
fi

# Updating invenroty file
size=$(du -h /tmp/${myname}-httpd-logs-${timestamp}.tar | awk '{print $1}')
logType="httpd-logs"
type="tar"
echo "<br>${logType}&nbsp;&nbsp;&nbsp;&nbsp;${timestamp}&nbsp;&nbsp;&nbsp;&nbsp;${type}&nbsp;&nbsp;&nbsp;&nbsp;${size}">>/var/www/html/inventory.html
echo "Inventory file is updated";

# Creation of cron job
if [ -f /etc/cron.d/automation ]
then
        echo "Cron job is already in place"
else
        touch /etc/cron.d/automation
        echo "0 0 * * * root /root/Automation_Project/Automation.sh" > /etc/cron.d/automation
        echo "New cron job has been scheduled"
fi