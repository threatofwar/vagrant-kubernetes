# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  node_name = "k8s-controlplane"

  config.vm.define node_name do |node|
    node.vm.box = "ubuntu/jammy64"
    node.vm.hostname = node_name

    # Get the network adapter name
    network_adapter_name = %x[powershell -Command "(Get-NetRoute -DestinationPrefix 0.0.0.0/0 | Get-NetAdapter | Select-Object -ExpandProperty InterfaceDescription).Trim()"]
    network_adapter_name.strip!

    # Validate the adapter name
    if network_adapter_name.nil? || network_adapter_name.empty?
      raise "network_adapter_name failed"
    end

    puts "network adapter: #{network_adapter_name}"

    node.vm.network "public_network", bridge: network_adapter_name

    node.vm.provider "virtualbox" do |vb|
      vb.name = node_name
      vb.memory = "2048"
      vb.cpus = 2
    end

    node.vm.provision "shell", path: "scripts/install-kubelet-kubeadm-kubectl.sh"
    node.vm.provision "shell", path: "scripts/install-container-runtime.sh"
  end
end
