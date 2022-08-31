#!/bin/bash

set -euxo pipefail

## setup
echo "installing dependencies ..."
sudo apt-get update
sudo apt-get install -y \
    vim \
    httpie \
    jq \
    git \
    unzip \
    clang-11 \
    llvm-11 \
    bison \
    cmake \
    arping \
    python3-pip \
    python3-invoke \
    linux-headers-$(uname -r) \
    libelf-dev \
    flex \
    netperf \
    iperf \
    linux-tools-common \
    apt-file \
    bison \
    build-essential \
    cmake \
    flex \
    git \
    libedit-dev \
    libllvm11 \
    llvm-11-dev \
    libclang-11-dev \
    python3 \
    zlib1g-dev \
    libelf-dev \
    libfl-dev \
    ninja-build \
    gcc-multilib # only on x64, used for syscall testers

# Update alternatives to make python3 the default
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1
sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-11 1
sudo update-alternatives --install /usr/bin/llc llc /usr/bin/llc-11 1

# Install Go
GO_VERSION=1.18.5
wget -q https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz

mkdir -p /home/vagrant/go

echo 'export GOROOT=/usr/local/go' >> ~/.profile
echo 'export GOPATH=/home/vagrant/go' >> ~/.profile
echo 'export PATH=/home/vagrant/go/bin:/usr/local/go/bin:/home/vagrant/.local/bin:$PATH' >> ~/.profile
source ~/.profile

# check go install
go version

# install bpf specific clang and llc
sudo mkdir -p /opt/datadog-agent/embedded/bin
sudo cp /vagrant/binaries/$(uname -m)/clang /opt/datadog-agent/embedded/bin/clang-bpf
sudo chown root:root /opt/datadog-agent/embedded/bin/clang-bpf
sudo chmod +x /opt/datadog-agent/embedded/bin/clang-bpf
sudo cp /vagrant/binaries/$(uname -m)/llc /opt/datadog-agent/embedded/bin/llc-bpf
sudo chown root:root /opt/datadog-agent/embedded/bin/llc-bpf
sudo chmod +x /opt/datadog-agent/embedded/bin/llc-bpf

# setup eBPF dir
sudo mkdir -p /opt/datadog-agent/embedded/share/system-probe/ebpf/runtime
sudo chown vagrant:vagrant -R /opt/datadog-agent/embedded/share/system-probe/ebpf/runtime

# datadog-agent requirements
pushd ~/dd/datadog-agent

echo "installing the agent dependencies ..."
pip install -r requirements.txt
inv -e deps
inv -e install-tools

# This directory, where the sysprobe.sock is created, is usually created by Datadog Agent install package, and it's owned by dd-agent, not root. For local testing, we need to manually create this dir and have it owned by root.
sudo mkdir -p /opt/datadog-agent/run/
sudo mkdir -p /etc/datadog-agent/

echo "writing agent yamls if they do not already exist. insert your own API key to /etc/datadog-agent/security-agent.yaml"
system_probe_yaml="/etc/datadog-agent/system-probe.yaml"
tmp_system_probe_yaml="/tmp/system-probe.yaml"
if [[ ! -e $system_probe_yaml ]]; then
  echo "system_probe_config:
  log_level: debug
  enabled: true

runtime_security_config:
   enabled: true
   policies:
    dir: ~/security-agent-policies/runtime

network_config:
  enabled: false" > $tmp_system_probe_yaml

  sudo mv $tmp_system_probe_yaml $system_probe_yaml
fi

security_agent_yaml="/etc/datadog-agent/security-agent.yaml"
tmp_security_agent_yaml="/tmp/security-agent.yaml"
if [[ ! -e $security_agent_yaml ]]; then
  echo "api_key: [your_dd_api_key]
runtime_security_config:
  enabled: true

compliance_config:
  enabled: false" > $tmp_security_agent_yaml

  sudo mv $tmp_security_agent_yaml $security_agent_yaml
fi

sudo chown root:root /etc/datadog-agent/*

echo "alias cda=\"cd ~/dd/datadog-agent\"" >> ~/.profile

echo "done! \"source ~/.profile\" to get the shortcut \"cda\" to cd into the datadog-agent directory"

popd