#!/usr/bin/env bash

source .env

echo "Copy Telegraf configuration"
cp config/telegraf.conf.sample config/telegraf.conf
sed -i "s/{influx_token}/${INFLUX_TOKEN}/g" config/telegraf.conf
sed -i "s/{influx_org}/${INFLUX_TOKEN}/g" config/telegraf.conf
sed -i "s/{influx_bucket}/${INFLUX_BUCKET}/g" config/telegraf.conf
sed -i "s/{influx_url}/${INFLUX_URL}/g" config/telegraf.conf

echo "Copy deamon configuration"
cp config/deamon.json /etc/docker/daemon.json

systemctl restart docker

echo "Start Telegraf"
docker compose -f compose-client.yml up -d telegraf
