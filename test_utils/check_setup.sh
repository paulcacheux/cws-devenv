#!/bin/bash

set -euxo pipefail

cd ~/dd/datadog-agent

# general build
inv -e system-probe.build
inv -e security-agent.build

# functional tests
inv -e security-agent.build-embed-syscall-tester
inv -e security-agent.build-embed-latency-tools
inv -e security-agent.build-functional-tests

# constants
inv -e security-agent.functional-tests --testflags "-test.v -test.run TestOctogon"