#!/bin/bash
mkdir -p ~/workspace
cd ~/workspace

IFNAME=$1
BASE_IP="$(ip -4 addr show $IFNAME | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1 | cut -d "." -f1-3)"
MASTER_ADDRESS=$BASE_IP.11
VERSION=v1.13.0

wget -q --https-only --timestamping \
  https://storage.googleapis.com/kubernetes-release/release/$VERSION/bin/linux/amd64/kubectl \
  https://storage.googleapis.com/kubernetes-release/release/$VERSION/bin/linux/amd64/kube-proxy \
  https://storage.googleapis.com/kubernetes-release/release/$VERSION/bin/linux/amd64/kubelet

mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes

chmod +x kubectl kube-proxy kubelet
mv kubectl kube-proxy kubelet /usr/local/bin/

scp -o "StrictHostKeyChecking no" -i /home/vagrant/.ssh/id_rsa vagrant@$MASTER_ADDRESS:/tmp/ca.crt /var/lib/kubernetes/ca.crt

cat <<EOF | sudo tee /var/lib/kubelet/bootstrap-kubeconfig.yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /var/lib/kubernetes/ca.crt
    server: https://$MASTER_ADDRESS:6443
  name: bootstrap
contexts:
- context:
    cluster: bootstrap
    user: kubelet-bootstrap
  name: bootstrap
current-context: bootstrap
kind: Config
preferences: {}
users:
- name: kubelet-bootstrap
  user:
    token: 07401b.f395accd246ae52d
EOF

cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.crt"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.96.0.10"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
rotateCertificates: true
EOF

cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --bootstrap-kubeconfig=/var/lib/kubelet/bootstrap-kubeconfig.yaml \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --cert-dir=/var/lib/kubelet/pki/ \\
  --rotate-certificates=true \\
  --rotate-server-certificates=true \\
  --network-plugin=cni \\
  --register-node=true \\
  --v=2 \\
  --cgroup-driver=systemd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

rm -rf /etc/systemd/system/kubelet.service.d
systemctl daemon-reload
systemctl enable kubelet
systemctl start kubelet
