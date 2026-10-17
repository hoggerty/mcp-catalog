# Сборка и публикация MCP-каталога.
#   make check                 — проверить описания серверов и образы
#   make test                  — добавить серверы в локальный тестовый профиль
#   make release VERSION=v2    — собрать, опубликовать каталог и поставить git-тег

REGISTRY ?= ghcr.io/hoggerty
NAME     ?= mcp-catalog
TITLE    ?= hoggerty MCP
CATALOG  := $(REGISTRY)/$(NAME)

SERVERS      := $(wildcard servers/*.yaml)
TEST_PROFILE ?= catalog-test

MCP_CATALOGS_DIR := $(HOME)/.docker/mcp/catalogs/$(notdir $(REGISTRY))
SERVER_FLAGS     := $(foreach f,$(SERVERS),--server file://$(MCP_CATALOGS_DIR)/$(notdir $(f)))

.PHONY: help
help:
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-14s %s\n", $$1, $$2}'

.PHONY: check
check: check-tags check-images ## все проверки перед релизом

.PHONY: check-tags
check-tags: ## у каждого образа закреплена версия (не latest и не без тега)
	@bad=$$(grep -H '^image:' $(SERVERS) | grep -Ev 'image: *[^ ]+:[0-9][^ ]*$$|@sha256:'); \
	if [ -n "$$bad" ]; then echo "Images without exact versions:"; echo "$$bad"; exit 1; fi
	@echo "Ok: All images has exact versions"

.PHONY: check-images
check-images: ## каждый образ скачивается анонимно
	@tmp=$$(mktemp -d); \
	for img in $$(grep -h '^image:' $(SERVERS) | awk '{print $$2}'); do \
	  echo "pull $$img"; \
	  docker --config $$tmp pull -q $$img >/dev/null || { rm -rf $$tmp; echo "Can not download anonymously: $$img"; exit 1; }; \
	done; rm -rf $$tmp
	@echo "Ok: All images is public"

.PHONY: sync-local-catalog
sync-local-catalog: ## скопировать servers/*.yaml в ~/.docker/mcp/catalogs (требование docker mcp для file://)
	@mkdir -p $(MCP_CATALOGS_DIR)
	@cp $(SERVERS) $(MCP_CATALOGS_DIR)/

.PHONY: test
test: sync-local-catalog ## добавить серверы из servers/ в локальный профиль для ручной проверки
	-docker mcp profile create --name $(TEST_PROFILE)
	@for f in $(SERVERS); do docker mcp profile server add $(TEST_PROFILE) --server file://$(MCP_CATALOGS_DIR)/$$(basename $$f); done
	@echo "Configure secrets and parameters in Docker Desktop → MCP Toolkit → profile $(TEST_PROFILE)"

.PHONY: build
build: guard-version check sync-local-catalog ## собрать каталог локально
	docker mcp catalog create $(CATALOG):$(VERSION) --title "$(TITLE)" $(SERVER_FLAGS)
	docker mcp catalog show $(CATALOG):$(VERSION) --format yaml

.PHONY: push
push: guard-version ## опубликовать собранный каталог
	docker mcp catalog push $(CATALOG):$(VERSION)

.PHONY: release
release: guard-version guard-clean build push ## build + push + git-тег
	git tag -a $(VERSION) -m "catalog $(VERSION)"
	git push origin $(VERSION)
	@echo "Published $(CATALOG):$(VERSION). Update version in README."

.PHONY: guard-version
guard-version:
	@case "$(VERSION)" in v[0-9]*) ;; *) echo "Needed to set VERSION, for example: make release VERSION=v2"; exit 1;; esac

.PHONY: guard-clean
guard-clean:
	@git diff --quiet && git diff --cached --quiet || { echo "Has uncommited changes"; exit 1; }