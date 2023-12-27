#!/bin/bash

set -x
set -e

/home/ansible/build_vms_from_tag.sh \
  --allow-untagged true \
  --remote-derivative-packages true
