#!/bin/bash

# update and Java install;
apt-get update
apt-get install -y openjdk-11-jre-headless

# tomcat user, group, directory;
groupadd tomcat
useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

#tomcat .gz download, doing permissions and add to tomcat group;
cd /tmp
curl -O https://downloads.apache.org/tomcat/tomcat-9/v9.0.41/bin/apache-tomcat-9.0.41.tar.gz
mkdir /opt/tomcat
tar xzvf apache-tomcat-*tar.gz -C /opt/tomcat --strip-components=1
cd /opt/tomcat
chgrp -R tomcat /opt/tomcat
chmod -R g+r conf
chmod g+x conf
chown -R tomcat webapps/ work/ temp/ logs/

# .service and .xml modification;
cat > /etc/systemd/system/tomcat.service << EOF
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl status tomcat
sudo systemctl enable tomcat


# creating setevn.sh; 
sudo cat >> /opt/tomcat/bin/setenv.sh << EOF
export SPRING_DATASOURCE_url=jdbc:postgresql://192.168.56.102:5432/chinook
export SPRING_DATASOURCE_USERNAME=vagrant
export SPRING_DATASOURCE_PASSWORD=vagrant
EOF

#copy web.war;
sudo cp /tmp/web.war /opt/tomcat/webapps/web.war

sudo systemctl restart tomcat
sudo systemctl status tomcat
