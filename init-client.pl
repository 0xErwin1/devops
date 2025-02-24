#!/usr/bin/env perl

use strict;
use warnings;
use File::Copy;

my $ID = `id -u`;
if ($ID != 0) {
    die("Error: This script must be run as root");
}

die("Error: INFLUX_TOKEN is not defined")  unless defined($ENV{'INFLUX_TOKEN'});
die("Error: INFLUX_ORG is not defined")    unless defined($ENV{'INFLUX_ORG'});
die("Error: INFLUX_BUCKET is not defined") unless defined($ENV{'INFLUX_BUCKET'});
die("Error: INFLUX_URL is not defined")    unless defined($ENV{'INFLUX_URL'});

my $DOCKER_CONFIG_FILE_PATH        = "config/daemon.json";
my $DOCKER_SYSTEM_CONFIG_FILE_PATH = "/etc/docker/daemon.json";
my $TELEGRAF_FILE_PATH             = "config/telegraf.conf";
my $TELEGRAF_SAMPLE_FILE_PATH      = $TELEGRAF_FILE_PATH . ".sample";

my $INFLUX_TOKEN  = $ENV{'INFLUX_TOKEN'};
my $INFLUX_ORG    = $ENV{'INFLUX_ORG'};
my $INFLUX_BUCKET = $ENV{'INFLUX_BUCKET'};
my $INFLUX_URL    = $ENV{'INFLUX_URL'};

print("Copy Telegraf configuration\n");

open(my $telegraf_file_in, '<', $TELEGRAF_SAMPLE_FILE_PATH)
    or die("Could not open file '$TELEGRAF_SAMPLE_FILE_PATH' $!");
open(my $telegraf_file_out, '>', $TELEGRAF_FILE_PATH) or die("Could not open file '$TELEGRAF_FILE_PATH' $!");

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
copy("config/deamon.json", "/etc/docker/daemon.json") or die("Error: Could not copy deamon.json");

print("Start Telegraf\n");

my $status = system("docker compose -f compose-client.yml up -d telegraf");
die("Error: Telegraf could not be started") if $status != 0;
