# -*- mode: ruby -*-
# vi:set ft=ruby sw=2 ts=2 sts=2:

# Define the number of master and worker nodes
# If this number is changed, remember to update setup-hosts.sh script with the new hosts IP details in /etc/hosts of each VM.
NUM_WORKER_NODE = 2

IP_NW = "192.168.5."
MASTER_IP_START = 10
NODE_IP_START = 20

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  # config.vm.box = "base"
  config.vm.box = "ubuntu/bionic64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Provision Master Nodes
  config.vm.define "master" do |node|
    # Name shown in the GUI
    node.vm.provider "virtualbox" do |vb|
        vb.name = "kubernetes-master"
        vb.memory = 2048
        vb.cpus = 2
    end
    node.vm.hostname = "master"
    node.vm.network :private_network, ip: IP_NW + "#{MASTER_IP_START + 1}"
    node.vm.network "forwarded_port", guest: 22, host: "#{2711}"

    node.vm.provision "setup-hosts", :type => "shell", :path => "ubuntu/vagrant/setup-hosts.sh" do |s|
      s.args = ["enp0s8"]
    end

    node.vm.provision "setup-dns", type: "shell", :path => "ubuntu/update-dns.sh"
    node.vm.provision "copy-ssh-private", type: "file", source: "./ssh/id_rsa", destination: "~/.ssh/id_rsa"
    node.vm.provision "copy-ssh-public", type: "file", source: "./ssh/id_rsa.pub", destination: "~/.ssh/id_rsa.pub"
    node.vm.provision "authorize-ssh-key", type: "shell", :path => "ubuntu/authorize-ssh-key.sh"
    node.vm.provision "install-docker", type: "shell", :path => "ubuntu/install-docker.sh"
    node.vm.provision "install-k8s", :type => "shell", :path => "ubuntu/install-k8s.sh"
    node.vm.provision "k8s-provision-certs", :type => "shell", :path => "k8s/master/01-provision-certs.sh"
    node.vm.provision "k8s-generate-kubeconfigs", :type => "shell", :path => "k8s/master/02-generate-kubeconfigs.sh"
    node.vm.provision "k8s-generate-encryption-key", :type => "shell", :path => "k8s/master/03-generate-encryption-key.sh"
    node.vm.provision "k8s-install-etcd", :type => "shell", :path => "k8s/master/04-install-etcd.sh"
    node.vm.provision "k8s-install-controlplane", :type => "shell", :path => "k8s/master/05-install-controlplane.sh"
    node.vm.provision "k8s-configure-kubectl", :type => "shell", :path => "k8s/master/06-configure-kubectl.sh"
    node.vm.provision "k8s-create-worker-bootstrap", :type => "shell", :path => "k8s/master/07-create-worker-bootstrap.sh"
    node.vm.provision "k8s-create-weave-start-script", :type => "shell", :path => "k8s/master/08-create-weave-start-script.sh"
    node.vm.provision "k8s-create-coredns-start-script", :type => "shell", :path => "k8s/master/09-create-coredns-start-script.sh"
    node.vm.provision "k8s-configure-kubeapi-perms", :type => "shell", :path => "k8s/master/10-configure-kubeapi-to-kubelet-perms.sh"

  end

  # Provision Worker Nodes
  (1..NUM_WORKER_NODE).each do |i|
    config.vm.define "worker-#{i}" do |node|
        node.vm.provider "virtualbox" do |vb|
            vb.name = "kubernetes-ha-worker-#{i}"
            vb.memory = 512
            vb.cpus = 1
        end
        node.vm.hostname = "worker-#{i}"
        node.vm.network :private_network, ip: IP_NW + "#{NODE_IP_START + i}"
		    node.vm.network "forwarded_port", guest: 22, host: "#{2720 + i}"

        node.vm.provision "setup-hosts", :type => "shell", :path => "ubuntu/vagrant/setup-hosts.sh" do |s|
          s.args = ["enp0s8"]
        end

        node.vm.provision "setup-dns", type: "shell", :path => "ubuntu/update-dns.sh"
        node.vm.provision "copy-ssh-private", type: "file", source: "./ssh/id_rsa", destination: "~/.ssh/id_rsa"
        node.vm.provision "copy-ssh-public", type: "file", source: "./ssh/id_rsa.pub", destination: "~/.ssh/id_rsa.pub"
        node.vm.provision "authorize-ssh-key", type: "shell", :path => "ubuntu/authorize-ssh-key.sh"
        node.vm.provision "install-docker", type: "shell", :path => "ubuntu/install-docker.sh"
        node.vm.provision "allow-bridge-nf-traffic", :type => "shell", :path => "ubuntu/allow-bridge-nf-traffic.sh"
        node.vm.provision "install-k8s", :type => "shell", :path => "ubuntu/install-k8s.sh"
        node.vm.provision "k8s-install-kubelet", :type => "shell", :path => "k8s/worker/01-install-kubelet.sh"
        node.vm.provision "k8s-install-kubeproxy", :type => "shell", :path => "k8s/worker/02-install-kubeproxy.sh"
        node.vm.provision "k8s-install-weave", :type => "shell", :path => "k8s/worker/03-install-weave.sh"
        node.vm.provision "k8s-install-coredns", :type => "shell", :path => "k8s/worker/04-install-coredns.sh"

    end
  end
end
