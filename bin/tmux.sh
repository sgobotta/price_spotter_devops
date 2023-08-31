#!/bin/bash

# ------------------------------------------------------------------------------
# Globals
#

# ------------------------------------------------------------------------------
# Sessions
#

dev() {
  ssh ${DEV_USER}@${DEV_HOST} -p ${DEV_PORT}
}

stage() {
  ssh ${STAGE_USER}@${STAGE_HOST} -p ${STAGE_PORT}
}

# ------------------------------------------------------------------------------
# Commands
#

case $1 in
  dev) "$@"; exit;;
esac