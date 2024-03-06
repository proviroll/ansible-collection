#!/bin/bash

set -eux

apt-get -qqq --yes install anacron awscli lz4 python3 aria2

export DEBIAN_FRONTEND=noninteractive

# Setup cron jobs
cp polkadot_cron_job /etc/cron.daily/

nohup bash run_polkadot_node.sh > ../logs/run_polkadot_node_log.txt 2>&1 &
