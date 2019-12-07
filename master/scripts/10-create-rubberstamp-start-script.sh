#!/bin/bash

mkdir -p ~/workspace
cd ~/workspace

cat > /tmp/start-rubberstamp.sh << EOF
#!/bin/bash
kubectl -n kube-system apply -f /home/vagrant/workspace/kubelet-rubber-stamp/service_account.yaml
kubectl -n kube-system apply -f /home/vagrant/workspace/kubelet-rubber-stamp/role.yaml
kubectl -n kube-system apply -f /home/vagrant/workspace/kubelet-rubber-stamp/role_binding.yaml
kubectl -n kube-system apply -f /home/vagrant/workspace/kubelet-rubber-stamp/operator.yaml
EOF

chmod +x /tmp/start-rubberstamp.sh
