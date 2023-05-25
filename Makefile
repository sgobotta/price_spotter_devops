.PHONY: help start stop setup test

# ------------------------------------------------------------------------------
# Environment setup
#

ENV_FILE ?= .env

# add env variables if needed
ifneq (,$(wildcard ${ENV_FILE}))
	include ${ENV_FILE}
    export
endif

export GREEN=\033[0;32m
export NOFORMAT=\033[0m

# ------------------------------------------------------------------------------
# Commands
#

default: help

#🐳 redis.cli: @ Starts a redis instance
redis.cli: SHELL:=/bin/bash
redis.cli: REDIS_PASS:=${REDIS_PASS}
redis.cli:
	@docker compose exec redis sh -c 'redis-cli -a ${REDIS_PASS}'

#❓ help: @ Displays this message
help: SHELL:=/bin/bash
help:
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(firstword $(MAKEFILE_LIST))| tr -d '#'  | awk 'BEGIN {FS = ":.*?@ "}; {printf "${GREEN}%-30s${NOFORMAT} %s\n", $$1, $$2}'

#🐳 start: @ Starts tilt services
start: SHELL:=/bin/bash
start:
	@echo Starting Tilt...
	@tilt up

#🐳 stop: @ Stop tilt services
stop:
	@echo Stopping Tilt...
	@tilt down

#🎁 redis.flush: @ Convenience funcion to flush redis keys in docker-compose deployments.
redis.flush: REDIS_PASS:=${REDIS_PASS}
redis.flush:
	@docker compose exec -e REDISCLI_AUTH=${REDIS_PASS} redis redis-cli FLUSHALL
