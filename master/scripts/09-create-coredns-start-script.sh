#!/bin/bash

mkdir -p ~/workspace
cd ~/workspace

cat > /tmp/start-coredns.sh << EOF
#!/bin/bash
kubectl apply -f https://raw.githubusercontent.com/mmumshad/kubernetes-the-hard-way/master/deployments/coredns.yaml
EOF

chmod +x /tmp/start-coredns.sh