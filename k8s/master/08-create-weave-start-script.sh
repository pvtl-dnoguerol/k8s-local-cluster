#!/bin/bash

mkdir -p ~/workspace
cd ~/workspace

cat > /tmp/start-weave.sh << EOF
#!/bin/bash
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
EOF

chmod +x /tmp/start-weave.sh