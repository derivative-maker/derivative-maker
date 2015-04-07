#!/usr/bin/make -f

## Copyright (C) 2012 - 2014 Patrick Schleizer <adrelanos@riseup.net>
## See the file COPYING for copying conditions.

## Bootstrapping genmkfile. Using genmkfile to build genmkfile.
## Using genmkfile without having genmkfile available as a build dependency.

GENMKFILE_BOOTSTRAP ?= ./packages/genmkfile/usr/share/genmkfile
GENMKFILE_PATH ?= $(GENMKFILE_BOOTSTRAP)
GENMKFILE_ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

export GENMKFILE_BOOTSTRAP
export GENMKFILE_PATH
export GENMKFILE_ROOT_DIR

include $(GENMKFILE_BOOTSTRAP)/makefile-full
