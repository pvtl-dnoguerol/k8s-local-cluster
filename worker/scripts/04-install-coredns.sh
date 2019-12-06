#!/bin/bash
mkdir -p ~/workspace
cd ~/workspace

MASTER_ADDRESS=$1

# This technically does not need to run on the worker node nor does it need
# to run more than once; it's done here as a workaround to trigger it after 
# the master node has been created.
ssh -o "StrictHostKeyChecking no" -i /home/vagrant/.ssh/id_rsa vagrant@$MASTER_ADDRESS '/tmp/start-coredns.sh'
