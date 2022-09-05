#!/bin/bash
apt -y update
apt -y install nginx
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
rm /var/www/html/index.*
cat <<EOF > /var/www/html/index.html
<html>
<H2>Build by Terraform</H2>
Owner of this document ${f_name}<br>
Lesson5<br>
ip: $myip<br>
Names from array:<br>
%{ for x in names ~}
:${x}<br>
%{ endfor ~}
<br><font color="magenta">
<b>Version 2</b>
</html>
EOF
service nginx start