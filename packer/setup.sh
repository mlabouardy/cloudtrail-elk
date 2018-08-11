#!/bin/bash

echo "Install Java JDK 8"
apt-get update
apt-get install openjdk-8-jre -y

echo "Install ElasticSearch 6"
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-6.x.list
apt-get update
apt-get install -y elasticsearch
chown -R elasticsearch:elasticsearch /usr/share/elasticsearch
mv /tmp/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml

echo "Start ElasticSearch"
systemctl enable elasticsearch.service
systemctl start elasticsearch.service

echo "Install Logstash"
apt-get install -y apt-transport-https
apt-get update
apt-get install -y logstash
mv /tmp/cloudtrail.conf /etc/logstash/conf.d/cloudtrail.conf

echo "Start Logstash"
systemctl enable logstash
systemctl start logstash

echo "Install Kibana"
apt-get install -y kibana
mv /tmp/kibana.yml /etc/kibana/kibana.yml

echo "Start Kibana"
systemctl enable kibana
systemctl start kibana