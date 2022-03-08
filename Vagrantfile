# -*- mode: ruby -*-
# vi: set ft=ruby :

# NOTE: `Vagrantfile`s are essentially Ruby scripts
# Ref: https://docs.vagrantup.com

# NOTE: Prefer `bento` to `hashicorp` as the former seems to be more up to date
# https://app.vagrantup.com/bento
LINUX_BASE_BOX = "bento/ubuntu-18.04"

# NOTE: Architecture
# Provision one server Virtual Machine (VM), and two client VMs.
# Ref: https://www.vagrantup.com/docs/multi-machine
# Docker, Consul, and Nomad will be installed in all three VMs.
# Consul, Nomad servers will run in the server VM.
Vagrant.configure("2") do |config|

    # Server VM
    # NOTE: IMPORTANT: Keep ip addresses in sync with `playbooks/roles/hashilab/defaults/main.yml`
    config.vm.define "server" do |server|
		server.vm.box = LINUX_BASE_BOX
		server.vm.hostname = "server"
		server.vm.network "private_network", ip: "172.20.20.10"
		server.vm.network "forwarded_port", guest: 8500, host: 8500     # Consul UI
		server.vm.network "forwarded_port", guest: 4646, host: 4646     # Nomad UI

        # Configure VM
		server = configureVirtualBox server

		# Provision necessary software
		server = configureProvisioners server
    end

	# Client VMs
	1.upto(2) do |n|
        config.vm.define "client#{n}" do |client|
            client.vm.box = LINUX_BASE_BOX
            client.vm.hostname = "client#{n}"
            client.vm.network "private_network", ip: "172.20.20.%d" % [20 + n]

            # Configure VM
            client = configureVirtualBox client

            # Provision necessary software
            client = configureProvisioners client
        end
	end

end

def configureVirtualBox(config, cpus: "2", memory: "2048")
    # NOTE: VirtualBox is freely available
	config.vm.provider "virtualbox" do |v|
		v.customize ["modifyvm", :id, "--cableconnected1", "on", "--audio", "none"]
		v.memory = memory
		v.cpus = cpus
	end

	return config
end

def configureProvisioners(config)
    # NOTE: Nomad requires Docker to be installed and running on the host alongside the Nomad agent.
    # Ref: https://www.nomadproject.io/docs/drivers/docker#client-requirements
    # We'll do this using a plugin https://github.com/leighmcculloch/vagrant-docker-compose
    # You can, of course, do this using a shell script, or Ansible
    config.vagrant.plugins = "vagrant-docker-compose"
    config.vm.provision :docker

    # NOTE: Use Ansible to provision the Vagrant box
    # Ref: https://www.vagrantup.com/docs/provisioning/ansible
    config.vm.provision "ansible" do |ansible|
        ansible.playbook = "./playbooks/hashilab.yml"
    end

	return config
end