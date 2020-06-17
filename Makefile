##############################################################
#    ______   _______  ___      __   __  _______  __    _ 
#   |      | |       ||   |    |  |_|  ||       ||  |  | |
#   |  _    ||   _   ||   |    |       ||    ___||   |_| |
#   | | |   ||  | |  ||   |    |       ||   |___ |       |
#   | |_|   ||  |_|  ||   |___ |       ||    ___||  _    |
#   |       ||       ||       || ||_|| ||   |___ | | |   |
#   |______| |_______||_______||_|   |_||_______||_|  |__|
#                     K8S DEVOPS TOOLKIT
##############################################################
## Author: Brice BROUSSOLLE <brice.broussolle@dolmen-tech.com
##############################################################

##############################
# STD VARS
##############################
_TITLE:=H4sIAD43fV4AA3VQ2w2EMAz77xQe4wY4PhBIPQnErxfx8NAkfQC6qoocx07SgnYAsCJPjYkwlIxHkiuEAJAs9SAqmFqyq2JjU/Np643KRC/RbT7IO+mvTWXJxhQbm62tdBeN01htY+0BJFrsjWK1JP8kIcCl6yDecmeuTAmvs3w2fKcj/zbsOa/LvJ8yr90opQEAAA==
_CURRENT_USER:=$(shell whoami)
_OS_ARG:=$(shell base64 --help| grep 'decode' | cut -d, -f1 | awk '{$$1=$$1};1' | cut -c1-2)
DATE:=`date +'%Y%m%d-%H%M%S'`
VERSION_MAJOR:=0
VERSION_MINOR:=6
VERSION_PATCH:=1
VERSION=$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)
.DEFAULT_GOAL := attach

##############################
# TYPO
##############################
_END   := $(shell tput -Txterm sgr0)
_BOLD  := $(shell tput -Txterm bold)
_UNDER := $(shell tput -Txterm smul)
_REV   := $(shell tput -Txterm rev)

# Colors
_GREY   := $(shell tput -Txterm setaf 0)
_RED    := $(shell tput -Txterm setaf 1)
_GREEN  := $(shell tput -Txterm setaf 2)
_YELLOW := $(shell tput -Txterm setaf 3)
_BLUE   := $(shell tput -Txterm setaf 4)
_PURPLE := $(shell tput -Txterm setaf 5)
_CYAN   := $(shell tput -Txterm setaf 6)
_WHITE  := $(shell tput -Txterm setaf 7)

# Inverted, i.e. colored backgrounds
_IGREY   := $(shell tput -Txterm setab 0)
_IRED    := $(shell tput -Txterm setab 1)
_IGREEN  := $(shell tput -Txterm setab 2)
_IYELLOW := $(shell tput -Txterm setab 3)
_IBLUE   := $(shell tput -Txterm setab 4)
_IPURPLE := $(shell tput -Txterm setab 5)
_ICYAN   := $(shell tput -Txterm setab 6)
_IWHITE  := $(shell tput -Txterm setab 7)

##############################
# APP VARS
##############################
IMAGE_NAME?=dolmen/kdt
BUMP_TYPE?=
GIT_MODIFICATION?=$(git diff-index --quiet HEAD -- || true);
FOLDER?=
AS_ROOT:=false
DEBUG:=false
PORT:=false
NETWORK:=false
HOSTNAME:=kdt-$(DATE)
DOCKER:=false
SHELL_DEBUG?=

ENV_ARGS := --rm --name "kdt-$(DATE)"
ifneq ($(FOLDER),)
	ENV_ARGS := $(ENV_ARGS) -v $(FOLDER):/home/devops/mounted -w /home/devops/mounted
endif

ifneq ($(DOCKER),false)
	ENV_ARGS := $(ENV_ARGS) -v /var/run/docker.sock:/var/run/docker.sock:rw
endif

ifeq ($(DEBUG), false)
	SHELL_DEBUG := > /dev/null 2>&1
endif

HELP_FUN = \
    %help; \
    while(<>) { push @{$$help{$$2 // 'options'}}, [$$1, $$3] if /^([a-zA-Z\-]+)\s*:.*\#\#(?:@([a-zA-Z\-]+))?\s(.*)$$/ }; \
    print "usage: make [target]\n\n"; \
    for (sort keys %help) { \
    print "${_WHITE}$$_:${_END}\n"; \
    for (@{$$help{$$_}}) { \
    $$sep = " " x (32 - length $$_->[0]); \
    print "  ${_YELLOW}$$_->[0]${_END}$$sep${_GREEN}$$_->[1]${_END}\n"; \
    }; \
    print "\n"; }

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
		$(error Undefined $1$(if $2, ($2))))

define _SPLASH
	@echo "${_TITLE}" | base64 $(_OS_ARG) | zcat 
	@echo "\n\t\t\t\t\t Version ${_BOLD}${_GREEN}${VERSION}${_END}\n"
endef

##############################
# TASKS
##############################
.PHONY: build remove attach a 
#- DOCKER TASKS
build: .splash						##@Commands Build local docker image of KDT
	$(info Build docker image $(IMAGE_NAME):$(VERSION))
	@docker build -t "$(IMAGE_NAME):$(VERSION)" . $(SHELL_DEBUG)

remove: .splash						##@Commands Remove local docker image of KDT
	$(info Remove docker image $(IMAGE_NAME):$(VERSION))
	@docker rmi -f "$(IMAGE_NAME):$(VERSION)" $(SHELL_DEBUG)

clean: .splash						##@Commands Remove other images of KDT
	$(info Clean other versions)
	$(eval IMG_TO_RM=$(foreach tag,$(shell docker images $(IMAGE_NAME) --format "{{.Tag}}"),$(if $(filter-out $(tag),$(VERSION)),$(IMAGE_NAME):$(tag))))
	@docker rmi -f $(IMG_TO_RM) $(SHELL_DEBUG)

a: attach
attach:										##@Commands Start a container of image KDT in interactive mode
	$(info Attach docker image $(IMAGE_NAME):$(VERSION))
ifneq ($(AS_ROOT),false)
	$(eval ENV_ARGS= $(ENV_ARGS) -u root)
endif
ifneq ($(PORT),false)
	$(eval ENV_ARGS= $(ENV_ARGS) -p $(PORT):$(PORT))
endif
ifneq ($(NETWORK),false)
	$(eval ENV_ARGS= $(ENV_ARGS) --network="$(NETWORK)" )
endif
ifeq (,$(wildcard $(HOME)/.history-kdt))
	$(shell touch $(HOME)/.history-kdt)
endif
	$(eval ENV_ARGS=$(ENV_ARGS) -v $(HOME)/.kube-kdt:/home/devops/.kube:Z)
	$(eval ENV_ARGS=$(ENV_ARGS) -v $(HOME)/.gcloud-kdt:/home/devops/.config/gcloud:Z)
	$(eval ENV_ARGS=$(ENV_ARGS) -v $(HOME)/.history-kdt:/home/devops/.bash_history:Z)	
	$(eval ENV_ARGS=$(ENV_ARGS) --hostname $(HOSTNAME))
	@docker run -it $(ENV_ARGS) $(IMAGE_NAME):$(VERSION)

#- VERSIONNING & PUBLISHING TASKS
.PHONY: publish version-bump
publish: .splash						##@Publishing Publish images into the registry
	$(info Publish new version $(VERSION))
	$(info - set tags)
	@docker tag $(IMAGE_NAME):$(VERSION) $(IMAGE_NAME):latest
	$(info - push images)
	@docker push $(IMAGE_NAME):$(VERSION)
	@docker push $(IMAGE_NAME):latest

version-bump: .splash			##@Publishing Bump version
	$(call check_defined, BUMP_TYPE)

ifeq ($(GIT_MODIFICATION), true)
	$(error Untraked file found)
endif

ifeq ($(BUMP_TYPE), patch)
	$(info Change Application version)
	$(info - Increment patch number)
	$(eval VERSION_PATCH=$(shell echo $$(($(VERSION_PATCH)+1))))
endif

ifeq ($(BUMP_TYPE), minor)
	$(info Change Application version)
	$(info - Increment minor number)
	$(eval VERSION_MINOR=$(shell echo $$(($(VERSION_MINOR)+1))))
	$(eval VERSION_PATCH=0)
endif

ifeq ($(BUMP_TYPE), major)
	$(info Change Application version)
	$(info - Increment major number)
	$(eval VERSION_MAJOR=$(shell echo $$(($(VERSION_MAJOR)+1))))
	$(eval VERSION_PATCH=0)
	$(eval VERSION_MINOR=0)
endif
	
	$(info - Change version number into the Makefile)
	@sed -i.bak -E 's@^VERSION_PATCH:=.+@VERSION_PATCH:=$(VERSION_PATCH)@g' ./Makefile
	@sed -i.bak -E 's@^VERSION_MINOR:=.+@VERSION_MINOR:=$(VERSION_MINOR)@g' ./Makefile
	@sed -i.bak -E 's@^VERSION_MAJOR:=.+@VERSION_MAJOR:=$(VERSION_MAJOR)@g' ./Makefile

	$(info - Make git modifications)
	@git add Makefile $(SHELL_DEBUG)
	@git commit -m "v$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)" $(SHELL_DEBUG)
	@git tag v$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH) $(SHELL_DEBUG)

	@echo new version : v$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)

	@if make .prompt-yesno message="Do you want push branch and tag" 2> /dev/null; then \
		git push; \
		git push --tags; \
	fi

help: .splash					##@Other Display this help
	@perl -e '$(HELP_FUN)' $(MAKEFILE_LIST)


print-alias: 					##@Other Print shortcut command for your alias file
	@echo "make -f $(CURDIR)/Makefile FOLDER=\\\`pwd\\\`"

version: .splash			##@Other Get the current version
##############################
# PRIVATE TASKS
##############################
.prompt-yesno:
	@echo "$(message)? [y/N] " && read ans && [ $${ans:-N} = y ]

.splash: 
	$(call _SPLASH)
