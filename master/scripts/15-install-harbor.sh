#!/bin/bash

mkdir -p ~/workspace
cd ~/workspace

helm repo add harbor https://helm.goharbor.io
helm install harbor --set persistence.enabled=false --set expose.ingress.hosts.core=core.harbor.whizzosoftware.com --set expose.ingress.hosts.notary=notary.harbor.whizzosoftware.com --set expose.tls.enabled=false harbor/harbor
