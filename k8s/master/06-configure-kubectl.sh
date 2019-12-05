#!/bin/bash

mkdir -p ~/workspace
cd ~/workspace

MASTER_ADDRESS=192.168.5.11
CLUSTER_NAME=local

kubectl config set-cluster ${CLUSTER_NAME} \
  --certificate-authority=ca.crt \
  --embed-certs=true \
  --server=https://${MASTER_ADDRESS}:6443

kubectl config set-credentials admin \
  --client-certificate=admin.crt \
  --client-key=admin.key

kubectl config set-context ${CLUSTER_NAME} \
  --cluster=${CLUSTER_NAME} \
  --user=admin

kubectl config use-context ${CLUSTER_NAME}
