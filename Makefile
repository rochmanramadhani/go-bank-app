# Constant variables
POSTGRES_CONTAINER = postgres12
DB_NAME = bank_app
DB_USER = root
DB_PASSWORD = password

# Docker command prefix to avoid repetition of container name
DOCKER_EXEC = docker exec -it $(POSTGRES_CONTAINER)

# Docker commands
postgres-create:
	@echo "Creating postgres container..."
	@docker run --name $(POSTGRES_CONTAINER) -p 5432:5432 -e POSTGRES_USER=$(DB_USER) -e POSTGRES_PASSWORD=$(DB_PASSWORD) -d postgres:12-alpine
	@echo "Postgres container created."

postgres-stop:
	@echo "Stopping postgres container..."
	@docker stop $(POSTGRES_CONTAINER)
	@echo "Postgres container stopped."

postgres-start:
	@echo "Starting postgres container..."
	@docker start $(POSTGRES_CONTAINER)
	@echo "Postgres container started."

postgres-delete:
	@echo "Deleting postgres container..."
	@docker rm $(POSTGRES_CONTAINER)
	@echo "Postgres container deleted."

# Database commands
createdb:
	@echo "Creating database..."
	@$(DOCKER_EXEC) createdb --username=$(DB_USER) --owner=$(DB_USER) --echo $(DB_NAME)
	@echo "Database created."

dropdb:
	@echo "Dropping database..."
	@$(DOCKER_EXEC) dropdb --echo $(DB_NAME)
	@echo "Database dropped."

db-migrate:
	@echo "Migrating database..."
	@migrate -path db/migration -database "postgresql://$(DB_USER):$(DB_PASSWORD)@localhost:5432/$(DB_NAME)?sslmode=disable" --verbose up
	@echo "Database migrated."

db-rollback:
	@echo "Rolling back database..."
	@migrate -path db/migration -database "postgresql://$(DB_USER):$(DB_PASSWORD)@localhost:5432/$(DB_NAME)?sslmode=disable" --verbose down
	@echo "Database rolled back."

# Application commands
seed:
	@echo "Seeding database..."
	@go run cmd/seed/main.go
	@echo "Database seeded."

test:
	@echo "Running tests..."
	@go test -v ./...
	@echo "Tests passed."

run:
	@echo "Running server..."
	@go run ./main.go
	@echo "Server stopped."

build:
	@echo "Building server..."
	@go build -o bin/server ./main.go
	@echo "Server built."

# sqlc commands
sqlc:
	@echo "Generating sqlc..."
	@sqlc generate
	@echo "sqlc generated."

# Phony targets
.PHONY: postgres-create postgres-stop postgres-start postgres-delete \
        createdb dropdb db-migrate db-rollback \
        seed test run build \
        sqlc
