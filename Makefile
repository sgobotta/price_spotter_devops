.PHONY: help start stop setup test

# ------------------------------------------------------------------------------
# Environment setup
#

BINS_DIR = ./bin
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

#❓ help: @ Displays this message
help: SHELL:=/bin/bash
help:
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(firstword $(MAKEFILE_LIST))| tr -d '#'  | awk 'BEGIN {FS = ":.*?@ "}; {printf "${GREEN}%-30s${NOFORMAT} %s\n", $$1, $$2}'

#♻️  backup.cache: @   Creates a backup of the redis cache
backup.cache: SHELL:=/bin/bash
backup.cache: BACKUP_NAME:=dump_`date +%d-%m-%Y"_"%H_%M_%S`
backup.cache:
	@docker run --rm --volumes-from price_spotter_redis_service -v $(shell pwd)/backup/redis:/backup ubuntu tar cvf /backup/redis_${BACKUP_NAME}.tar /data

#♻️  backup.db: @   Creates a backup of the postgres db
backup.db: SHELL:=/bin/bash
backup.db: DB_USERNAME:=$(DB_USERNAME)
backup.db: BACKUP_NAME:=dump_`date +%d-%m-%Y"_"%H_%M_%S`.sql
backup.db:
	@docker exec -t price_spotter_postgres_service pg_dumpall -c -U ${DB_USERNAME} > ./backup/postgres/postgres_${BACKUP_NAME}

#♻️  restore.cache: @   Restores a cache backup for the redis service
restore.cache: SHELL:=/bin/bash
restore.cache: BACKUP_NAME:=$(BACKUP_NAME)
restore.cache:
	@docker run --rm --volumes-from price_spotter_redis_service -v $(pwd)/backup/redis:/backup ubuntu bash -c "cd /data && tar xvf /backup/backup.tar --strip 1"
	@docker compose restart redis

#♻️  restore.db: @   Restores a db backup for the postgres service
restore.db: SHELL:=/bin/bash
restore.db: DB_USERNAME:=${DB_USERNAME}
restore.db: DUMP_FILE:=$(DUMP_FILE)
restore.db:
	@cat backup/postgres/${DUMP_FILE} | docker exec -i price_spotter_postgres_service psql -U ${DB_USERNAME}

#🐳 redis.cli: @ Starts a redis instance
redis.cli: SHELL:=/bin/bash
redis.cli: REDIS_PASS:=${REDIS_PASS}
redis.cli:
	@docker compose exec redis sh -c 'redis-cli -a ${REDIS_PASS}'

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

#💻 connect.dev: @ Start dev a tmux session
connect.dev: SESSION:=dev
connect.dev: DEV_USER:=${DEV_USER}
connect.dev: DEV_HOST:=${DEV_HOST}
connect.dev:
	@${BINS_DIR}/tmux.sh ${SESSION}
