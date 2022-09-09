#!/bin/bash
apt -y update
apt -y install nginx
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
rm /var/www/html/index.*
echo "<h2>Yo! Skiff</H2><br>IP: $myip<br>Build by Terraform!" > /var/www/html/index.html
service nginx start