# to be done on all nodes
# 2 installing container runtime
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install containerd.io

# Configuring the systemd cgroup driver
# --Enable IPv4 packet forwarding
containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

sudo kubeadm init --apiserver-advertise-address "$(ip a show enp0s8 | grep inet | awk '{print $2}' | head -n 1 | cut -d/ -f1)" --pod-network-cidr "10.244.0.0/16" --upload-certs
mkdir -p /home/vagrant/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config

#kubectl taint nodes k8s-controlplane node.kubernetes.io/not-ready:NoSchedule-
sudo -u vagrant kubectl apply -f https://reweave.azurewebsites.net/k8s/v1.29/net.yaml
