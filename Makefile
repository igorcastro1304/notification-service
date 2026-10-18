-include .env
export

.PHONY: help tools up down reset ps logs topics psql redis-cli \
	tidy run-api

help: ## Lista os comandos
	@awk 'BEGIN {FS = ": ## "}; /^[a-zA-Z_-]+: ## / {printf "  %-14s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

up: ## Sobe Postgres, Redpanda, Redis e Console e cria os tópicos
	docker compose up -d --wait postgres redpanda redis console
	docker compose up init-topics

down: ## Para os containers (mantém os dados)
	docker compose down

reset: ## Para os containers e APAGA os dados
	docker compose down -v

ps: ## Estado dos containers
	docker compose ps

logs: ## Logs ao vivo
	docker compose logs -f

topics: ## Lista os tópicos do Redpanda
	docker compose exec redpanda rpk topic list

psql: ## Abre o psql no banco
	docker compose exec postgres psql -U notification_service -d notification_service

redis-cli: ## Abre o redis-cli
	docker compose exec redis redis-cli

tidy: ## Arruma o go.mod
	go mod tidy

run-api: ## Roda a API
	go run ./cmd/api