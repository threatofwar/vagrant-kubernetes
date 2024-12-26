# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # Configuration variables
  num_worker_nodes = 1
  worker_node_prefix = "k8s-worker"
  master_node_name = "k8s-controlplane"

  # Master node configuration
  nodes = [
    { name: master_node_name, memory: 2048, cpus: 2 } # Master node
  ]

  # Add worker nodes with specified memory and CPU settings
  (1..num_worker_nodes).each do |i|
    nodes << { name: "#{worker_node_prefix}#{i}", memory: 1024, cpus: 1 } # Worker nodes
  end

  # Get the network adapter name
  network_adapter_name = %x[powershell -Command "(Get-NetRoute -DestinationPrefix 0.0.0.0/0 | Get-NetAdapter | Select-Object -ExpandProperty InterfaceDescription).Trim()"]
  network_adapter_name.strip!

  # Validate the adapter name
  raise "network_adapter_name failed" if network_adapter_name.nil? || network_adapter_name.empty?

  puts "network adapter: #{network_adapter_name}"

  # Configure each node
  nodes.each do |node|
    config.vm.define node[:name] do |n|
      n.vm.box = "ubuntu/jammy64"
      n.vm.hostname = node[:name]
      n.vm.network "public_network", bridge: network_adapter_name

      n.vm.provider "virtualbox" do |vb|
        vb.name = node[:name]
        vb.memory = node[:memory]
        vb.cpus = node[:cpus]
      end

      # Provision scripts
      n.vm.provision "shell", path: "scripts/install-kubelet-kubeadm-kubectl.sh"
      n.vm.provision "shell", path: "scripts/install-container-runtime.sh"

      # Add kubeadm-init script only for the master node
      if node[:name] == master_node_name
        n.vm.provision "shell", path: "scripts/kubeadm-init.sh"
      end
      if node[:name] != master_node_name
        n.vm.provision "shell", path: "scripts/kubeadm-join.sh"
      end
    end
  end
end