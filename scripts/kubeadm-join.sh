while [ ! -f /vagrant/token_and_cert_hash.txt ]; do
echo "Waiting for master node to initialize..."
sleep 5
done
          
# Source the token and cert hash
source /vagrant/token_and_cert_hash.txt
          
# Join the worker node to the cluster
sudo kubeadm join $MASTER_IP:6443 --token $TOKEN --discovery-token-ca-cert-hash sha256:$CERT_HASH

# while [ ! -f /vagrant/config_temp ]; do
# echo "copy kube config into home"
# sleep 5
# done
# source /vagrant/config_temp

# mkdir -p /home/vagrant/.kube
# sudo cp /vagrant/config_temp /home/vagrant/.kube/config
# sudo chown vagrant:vagrant /home/vagrant/.kube/config