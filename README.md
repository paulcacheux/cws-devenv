# CWS development environment

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
inv -e security-agent.build-embed-syscall-tester
inv -e security-agent.build-embed-latency-tools
```

You can then run functional tests, where `-test.v` is used to run tests in verbose mode and `-test.run TestNameXXX` is the filter used to run a subset of tests:
```sh
inv -e security-agent.functional-tests --testflags "-test.v -test.run TestNameXXX"
```

You can also run functional tests in a docker container, with similar arguments:
```sh
inv -e security-agent.docker-functional-tests
```