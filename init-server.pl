#!/usr/bin/env perl

use strict;
use warnings;
use File::Copy;

my $ID = `id -u`;
if ($ID != 0) {
    die("Error: This script must be run as root");
}

my $DOCKER_CONFIG_FILE_PATH        = "config/daemon.json";
my $DOCKER_SYSTEM_CONFIG_FILE_PATH = "/etc/docker/daemon.json";
my $TELEGRAF_FILE_PATH             = "config/telegraf.conf";
my $TELEGRAF_SAMPLE_FILE_PATH      = $TELEGRAF_FILE_PATH . ".sample";
my $ENV_FILE_PATH                  = ".env";
my $ENV_FILE_SAMPLE_PATH           = ".env.sample";
my $exist_env_file                 = 0;
my $ENV_FILE                       = "";

if (-e $ENV_FILE_PATH) {
    print("Copy .env.sample to .env\n");
    copy($ENV_FILE_SAMPLE_PATH, ".env") or die("Error: Could not copy .env.sample");
    $exist_env_file = 1;
    open(my $ENV_FILE, '<', $ENV_FILE_PATH) or die("Could not open file '$ENV_FILE_PATH' $!");
}
else {
    open(my $ENV_FILE, '<', $ENV_FILE_SAMPLE_PATH) or die("Could not open file '$ENV_FILE_SAMPLE_PATH' $!");
}

my $INFLUX_USERNAME = $ENV{'INFLUX_USERNAME'} || "admin";
my $INFLUX_PASSWORD = $ENV{'INFLUX_PASSWORD'} || `openssl rand -base64 8`;
my $INFLUX_TOKEN    = $ENV{'INFLUX_TOKEN'}    || `openssl rand -base64 32`;
my $INFLUX_ORG      = $ENV{'INFLUX_ORG'}      || "ignis";
my $INFLUX_BUCKET   = $ENV{'INFLUX_BUCKET'}   || "monitoring";
my $INFLUX_URL      = $ENV{'INFLUX_URL'}      || "http://localhost:8086";

if ($exist_env_file) {
    print("Generating InfluxDB environment variables\n");
    ENV { 'INFLUX_USERNAME' } = $INFLUX_USERNAME;
    ENV { 'INFLUX_PASSWORD' } = $INFLUX_PASSWORD;
    ENV { 'INFLUX_TOKEN' }    = $INFLUX_TOKEN;
    ENV { 'INFLUX_ORG' }      = $INFLUX_ORG;
    ENV { 'INFLUX_BUCKET' }   = $INFLUX_BUCKET;
    ENV { 'INFLUX_URL' }      = $INFLUX_URL;

    while (my $line = <$ENV_FILE>) {
        $line =~ s/{influx_password}/$INFLUX_PASSWORD/g;
        $line =~ s/{influx_token}/$INFLUX_TOKEN/g;
        $line =~ s/{influx_retention}/4w/g;
        $line =~ s/{influx_org}/$INFLUX_ORG/g;
        $line =~ s/{influx_bucket}/$INFLUX_BUCKET/g;
        $line =~ s/{influx_username}/$INFLUX_USERNAME/g;
        print($ENV_FILE, $line);
    }
}

close($ENV_FILE);

print("Create InfluxDB volumes\n");
mkdir("influxdb-data");
chmod(0777, "influxdb-data");

print("Create Grafana volumes\n");
mkdir("grafana-data");
chmod(0777, "grafana-data");

print("Create loki volumes\n");
mkdir("loki-data");
chmod(0777, "loki-data");

print("Copy Telegraf configuration\n");

open(my $telegraf_file_in, '<', $TELEGRAF_SAMPLE_FILE_PATH)
    or die("Could not open file '$TELEGRAF_SAMPLE_FILE_PATH' $!");

open(my $telegraf_file_out, '>', $TELEGRAF_FILE_PATH) or die("Could not open file 'TELEGRAF_FILE_PATH' $!");

while (my $line = <$telegraf_file_in>) {
    $line =~ s/{influx_token}/$INFLUX_TOKEN/g;
    $line =~ s/{influx_org}/$INFLUX_ORG/g;
    $line =~ s/{influx_bucket}/$INFLUX_BUCKET/g;
    $line =~ s/{influx_url}/$INFLUX_URL/g;
    print($telegraf_file_out, $line);
}

close($telegraf_file_in);
close($telegraf_file_out);

print("Copy deamon configuration\n");
copy($DOCKER_CONFIG_FILE_PATH, "/etc/docker/daemon.json") or die("Error: Could not copy deamon.json");

print("Start Telegraf\n");

my $status = system("docker compose -f compose-server.yml up -d");
die("Error: Telegraf could not be started") if $status != 0;
