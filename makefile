all: check-vars build
user_exists = $(shell docker secret inspect basic-auth-user >/dev/null 2>&1 && echo $$?)
password_exists = $(shell docker secret inspect basic-auth-password >/dev/null 2>&1 && echo $$?)
network_exists = $(shell docker network inspect traefik-net >/dev/null 2>&1 && echo $$?)

check-vars:
ifndef DNS_SUFFIX
	$(error env var DNS_SUFFIX is not set)
endif
ifndef BRANCH_NAME
	$(error env var BRANCH_NAME is not set)
endif
ifndef SA_PASSWORD
	$(error env var SA_PASSWORD is not set)
endif

build-network:
ifeq (echo $(network_exists), 1)
	@docker network create --driver=overlay traefik-net
endif

#check-secrets:
#ifndef BRANCH_NAME
#	$(error env var BRANCH_NAME is not set)
#endif
#ifndef SA_PASSWORD
#	$(error env var SA_PASSWORD is not set)
#endif

#create-secrets: check-secrets
#ifeq (echo $(user_exists), 1)
#	@echo ${BRANCH_NAME} | docker secret create basic-auth-user -
#endif
#ifeq (echo $(password_exists), 1)
#	@echo ${SA_PASSWORD} | docker secret create basic-auth-password -
#endif

build: build-network
	@docker stack deploy -c docker-compose.yml mssql

refresh: destroy build

destroy:
	@docker stack rm mssql
	@sleep 2

destroy-all: destroy
	@-docker network rm traefik-net
