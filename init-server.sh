#!/usr/bin/env bash

echo "Copy .env.sample to .env"
cp .env.sample .env

echo "Generating InfluxDB environment variables"

INFLUX_TOKEN=$(openssl rand -base64 32)
sed -i "s/{influx_password}/$(openssl rand -base64 8)/g" .env
sed -i "s/{influx_token}/${INFLUX_TOKEN}/g" .env
sed -i "s/{influx_retention}/4w/g" .env
sed -i "s/{influx_org}/ignis/g" .env
sed -i "s/{influx_bucket}/monitoring/g" .env
sed -i "s/{influx_username}/admin/g" .env

echo "Create InfluxDB volumes"
mkdir -p influxdb-data
chmod 777 influxdb-data

echo "Create Grafana volumes"
mkdir -p grafana-data
chmod 777 grafana-data

echo "Create loki volumes"
mkdir -p loki-data
chmod 777 loki-data

echo "Copy Telegraf configuration"
cp config/telegraf.conf.sample config/telegraf.conf
sed -i "s/{influx_token}/${INFLUX_TOKEN}/g" config/telegraf.conf
sed -i "s/{influx_org}/ignis/g" config/telegraf.conf
sed -i "s/{influx_bucket}/monitoring/g" config/telegraf.conf

echo "Copy deamon configuration"
cp config/deamon.json /etc/docker/daemon.json

systemctl restart docker

docker compose -f compose-server.yml up -d
