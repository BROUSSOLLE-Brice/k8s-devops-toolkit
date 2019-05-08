IMAGE_NAME?=bipole3/kdt

VERSION_MAJOR:=0
VERSION_MINOR:=1
VERSION_PATCH:=0
VERSION=v$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)

VERSION_TYPE?=
GIT_MODIFICATION?=$(git diff-index --quiet HEAD -- || true);

FOLDER?=
DEBUG:=false
SHELL_DEBUG?=

DATE:=`date +'%Y%m%d-%H%M%S'`

ENV_ARGS := --rm --name "kdt-$(DATE)" --hostname "kdt-$(DATE)"
ENV_ARGS := $(ENV_ARGS) -p 8080:8080 -p 8443:8443
ifneq ($(FOLDER),)
	ENV_ARGS := $(ENV_ARGS) -v $(FOLDER):/home/devops/mounted -w /home/devops/mounted
endif

ifeq ($(DEBUG), false)
	SHELL_DEBUG := > /dev/null 2>&1
endif

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
		$(error Undefined $1$(if $2, ($2))))

image-build:
	$(info Build docker image $(IMAGE_NAME):$(VERSION))
	@docker build -t "$(IMAGE_NAME):$(VERSION)" . $(SHELL_DEBUG)

image-remove:
	$(info Remove docker image $(IMAGE_NAME):$(VERSION))
	@docker rmi -f "$(IMAGE_NAME):$(VERSION)" $(SHELL_DEBUG)

image-attach:
	$(info Attach docker image $(IMAGE_NAME):$(VERSION))
	$(eval ENV_ARGS=$(ENV_ARGS) -v $(HOME)/.kube:/home/devops/.kube:Z)
	@docker run -it $(ENV_ARGS) $(IMAGE_NAME):$(VERSION)

env-build:
	$(info Build docker environment)
	@docker-compose up -d $(SHELL_DEBUG)
	@docker-compose down $(SHELL_DEBUG)
	
env-attach:
	$(info Attach docker environment)
	$(eval ENV_ARGS=$(ENV_ARGS) -v k8s-devops-toolkit_kube:/home/devops/.kube:Z)
	@docker-compose run $(ENV_ARGS) kdt-machine

env-remove:
	$(info Remove docker environment)
	@docker-compose down -v --rmi all $(SHELL_DEBUG)

version:
	@echo $(VERSION)

version-change:
	$(call check_defined, VERSION_TYPE)

ifeq ($(GIT_MODIFICATION), true)
	$(error Untraked file found)
endif

ifeq ($(VERSION_TYPE), patch)
	$(info Change Application version)
	$(info - Increment patch number)
	$(eval VERSION_PATCH=$(shell echo $$(($(VERSION_PATCH)+1))))
endif

ifeq ($(VERSION_TYPE), minor)
	$(info Change Application version)
	$(info - Increment minor number)
	$(eval VERSION_MINOR=$(shell echo $$(($(VERSION_MINOR)+1))))
	$(eval VERSION_PATCH=0)
endif

ifeq ($(VERSION_TYPE), major)
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
