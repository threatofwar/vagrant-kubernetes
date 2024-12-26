sudo kubeadm init --apiserver-advertise-address "$(ip a show enp0s8 | grep inet | awk '{print $2}' | head -n 1 | cut -d/ -f1)" --pod-network-cidr "10.244.0.0/16" --upload-certs
mkdir -p /home/vagrant/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config
cp /etc/kubernetes/admin.conf /vagrant/config_temp

#kubectl taint nodes k8s-controlplane node.kubernetes.io/not-ready:NoSchedule-
sudo -u vagrant kubectl apply -f https://reweave.azurewebsites.net/k8s/v1.29/net.yaml
# Get the kubeadm join token and discovery token CA cert hash
TOKEN=$(kubeadm token list -o json | jq -r 'select(.kind == "BootstrapToken") | .token' | head -n 1)
CERT_HASH=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | \
            openssl rsa -pubin -outform der 2>/dev/null | \
            openssl dgst -sha256 -hex | awk '{print $2}')
MASTER_IP=$(ip a show enp0s8 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
          
# Store token and cert hash to a file
echo "TOKEN=${TOKEN}" > /vagrant/token_and_cert_hash.txt
echo "CERT_HASH=${CERT_HASH}" >> /vagrant/token_and_cert_hash.txt
echo "MASTER_IP=${MASTER_IP}" >> /vagrant/token_and_cert_hash.txt