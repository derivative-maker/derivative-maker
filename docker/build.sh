#!/bin/bash

set -x
set -e

MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "$MYDIR"

sudo -- docker build -t derivative-maker/derivative-maker-docker:latest .
