#!/bin/bash

## setup
printf "installing dependencies ...\n"
sudo apt-get update
sudo apt-get install -y vim httpie jq git unzip clang-11 llvm-11 bison cmake arping python3-pip python3-invoke linux-headers-$(uname -r) libelf-dev flex netperf iperf linux-tools-common apt-file
sudo apt-get install -y bison build-essential cmake flex git libedit-dev libllvm11 llvm-11-dev libclang-11-dev python3 zlib1g-dev libelf-dev libfl-dev

# Update alternatives to make python3 the default
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1
sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-11 1
sudo update-alternatives --install /usr/bin/llc llc /usr/bin/llc-11 1

# Install Go
wget https://go.dev/dl/go1.17.9.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.17.9.linux-amd64.tar.gz

echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
echo 'export GOPATH=/home/vagrant/go' >> ~/.bashrc
echo 'export PATH=/home/vagrant/go/bin:/usr/local/go/bin:/home/vagrant/.local/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

sudo chown vagrant /home/vagrant/go
sudo chown vagrant /home/vagrant/go/src/
sudo chown vagrant /home/vagrant/go/src/github.com/

# uncompress and install clang with eBPF backend
sudo mkdir -p /opt/datadog-agent/embedded/bin
sudo tar -xvf /vagrant/clang-ebpf-amd64-11.0.0.tar.xz -C /opt/datadog-agent/embedded

# datadog-agent requirements
cd ~/dd/datadog-agent || (echo "missing datadog-agent repository" && exit)
printf "\ninstalling the agent dependencies ...\n"
pip install -r requirements.txt
inv -e deps
inv -e install-tools

printf "\ndone !\n\n"
