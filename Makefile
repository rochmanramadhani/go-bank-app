# Constant variables
POSTGRES_CONTAINER = postgres12
DB_NAME = bank_app
DB_USER = root
DB_PASSWORD = password

# Docker command prefix to avoid repetition of container name
DOCKER_EXEC = docker exec -it $(POSTGRES_CONTAINER)

# Docker commands
docker-create-postgres:
	@echo "Creating postgres container..."
	@docker run --name $(POSTGRES_CONTAINER) -p 5432:5432 -e POSTGRES_USER=$(DB_USER) -e POSTGRES_PASSWORD=$(DB_PASSWORD) -d postgres:12-alpine
	@echo "Postgres container created."

docker-stop-postgres:
	@echo "Stopping postgres container..."
	@docker stop $(POSTGRES_CONTAINER)
	@echo "Postgres container stopped."

docker-start-postgres:
	@echo "Starting postgres container..."
	@docker start $(POSTGRES_CONTAINER)
	@echo "Postgres container started."

docker-delete-postgres:
	@echo "Deleting postgres container..."
	@docker rm $(POSTGRES_CONTAINER)
	@echo "Postgres container deleted."

# Database commands
db-create:
	@echo "Creating database..."
	@$(DOCKER_EXEC) createdb --username=$(DB_USER) --owner=$(DB_USER) --echo $(DB_NAME)
	@echo "Database created."

db-drop:
	@echo "Dropping database..."
	@$(DOCKER_EXEC) dropdb --echo $(DB_NAME)
	@echo "Database dropped."

db-migrate-up:
	@echo "Migrating database..."
	@migrate -path db/migration -database "postgresql://$(DB_USER):$(DB_PASSWORD)@localhost:5432/$(DB_NAME)?sslmode=disable" --verbose up
	@echo "Database migrated."

db-migrate-down:
	@echo "Rolling back database..."
	@migrate -path db/migration -database "postgresql://$(DB_USER):$(DB_PASSWORD)@localhost:5432/$(DB_NAME)?sslmode=disable" --verbose down
	@echo "Database rolled back."

# Application commands
app-seed:
	@echo "Seeding database..."
	@go run cmd/seed/main.go
	@echo "Database seeded."

app-test:
	@echo "Running tests..."
	@go test -v -cover ./...
	@echo "Tests passed."

app-run:
	@echo "Running server..."
	@go run ./main.go
	@echo "Server stopped."

app-build:
	@echo "Building server..."
	@go build -o bin/server ./main.go
	@echo "Server built."

# sqlc commands
sqlc-generate:
	@echo "Generating sqlc..."
	@sqlc generate
	@echo "sqlc generated."

# mockgen commands
mockgen-generate:
	@echo "Generating mockgen..."
	@mockgen -package mockdb -destination db/mock/store.go github.com/rochmanramadhani/go-bank-app/db/sqlc Store
	@echo "mockgen generated."

# Phony targets
.PHONY: docker-create-postgres docker-stop-postgres docker-start-postgres docker-delete-postgres \
        db-create db-drop db-migrate db-rollback \
        app-seed app-test app-run app-build \
        sqlc-generate \
        mockgen-generate
