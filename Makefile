PHONY :=
.DEFAULT_GOAL := help

DOCKER_IMAGE := druidfi/docker-s3cmd:latest

PHONY += build
build: ## Build image
	docker build --no-cache --force-rm . -t ${DOCKER_IMAGE}

PHONY += help
help: ## Print this help
	$(call colorecho, "\nAvailable make commands:")
	@cat $(MAKEFILE_LIST) | grep -e "^[a-zA-Z_\-]*: *.*## *" | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

PHONY += push
push: ## Push image
	docker push $(DOCKER_IMAGE)

PHONY += s3cmd-get
s3cmd-get: ## Test image
	docker run --rm -it --user=root -e ACCESS_KEY=${ACCESS_KEY} -e SECRET_KEY=${SECRET_KEY} -e S3_PATH=s3://${S3_PATH} ${DOCKER_IMAGE} get

PHONY += s3cmd-conf
s3cmd-conf: ## Show conf
	docker run --rm -it --user=root ${DOCKER_IMAGE} conf

PHONY += shell
shell: ## Test image
	docker run --rm -it --user=root ${DOCKER_IMAGE} sh

define colorecho
    @tput -T xterm setaf 3
    @echo $1
    @tput -T xterm sgr0
    @echo ""
endef

.PHONY: $(PHONY)
