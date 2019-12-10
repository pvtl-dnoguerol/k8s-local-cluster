#!/bin/bash

mkdir -p ~/workspace
cd ~/workspace

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml