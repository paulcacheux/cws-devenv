# CWS Cheat Sheet

## Invoke tasks

The Datadog agent uses `invoke` to run tasks. You can use both `invoke` or `inv` indistinctly. Use `-e` to display what underlying commands are run by `invoke`.

## Basic commands

Start the Vagrant VM:
```sh
>> vagrant up
>> vagrant ssh # to SSH into the VM
```

Build the system probe:
```sh
>> inv -e system-probe.build
```

Build the security agent:
```sh
>> inv -e security-agent.build
```

## Build and run functional tests

Before running tests you should build the syscall tester and latency tools:
```sh
>> inv -e security-agent.build-embed-syscall-tester
>> inv -e security-agent.build-embed-latency-tools
```

You can then run functional tests, where `-test.v` is used to run tests in verbose mode and `-test.run TestNameXXX` is the filter used to run a subset of tests:
```sh
>> inv -e security-agent.functional-tests --testflags "-test.v -test.run TestNameXXX"
```

You can also run functional tests in a docker container, with similar arguments:
```sh
>> inv -e security-agent.docker-functional-tests
```

# CWS Dev env setup

## Installing Vagrant

First install vagrant and virtualbox (this step should be a no-op for Datadog employees). You can then install a few helpful vagrant plugins:

```sh
>> vagrant plugin install vagrant-disksize vagrant-reload
```

## Booting the VM

Clone this repo (or copy `Vagrantfile`, `binaries/$ARCH` and  `setup.sh`), `cd` into it and run vagrant up.

Once the VM is booted, you can run
```sh
>> vagrant ssh
```
to ssh into the VM.

After the first boot, please run
```sh
>> /vagrant/setup.sh
```
to install required dependencies (`apt` packages, `go`, etc).
Then reboot the VM.

You can now `cd` into `~/dd/datadog-agent` and start building !