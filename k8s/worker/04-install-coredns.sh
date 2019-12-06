#!/bin/bash
mkdir -p ~/workspace
cd ~/workspace

IFNAME=$1
BASE_IP="$(ip -4 addr show $IFNAME | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1 | cut -d "." -f1-3)"
MASTER_ADDRESS=$BASE_IP.11

# This technically does not need to run on the worker node nor does it need
# to run more than once; it's done here as a workaround to trigger it after 
# the master node has been created.
ssh -o "StrictHostKeyChecking no" -i /home/vagrant/.ssh/id_rsa vagrant@$MASTER_ADDRESS '/tmp/start-coredns.sh'
