# Variables
DB_URL := $(DB_CONN)
GOOSE_DIR := ./sql/schema
SQLC_CONFIG := sqlc.yaml

# sql OR go
MIGRATION_TYPE := sql

.PHONY: build
build:
	go build -o bin/app main.go

.PHONY: run
run:
	go run main.go

.PHONY: fmt
fmt:
	go fmt ./...

.PHONY: sqlc
sqlc:
	sqlc generate --file $(SQLC_CONFIG)

# run this command using UNIX-like terminal like Git Bash on Windows
.PHONY: new-migration
new-migration:
	@if [ "$(name)" = "" ]; then \
		echo "Error: NAME is not set. Use 'make new-migration name=your_migration_name'"; \
		exit 1; \
	else \
		echo "Creating migration: $(name)"; \
		goose -dir $(GOOSE_DIR) create $(NAME) $(MIGRATION_TYPE); \
	fi

.PHONY: migrate-up
migrate-up:
	goose -dir $(GOOSE_DIR) postgres "$(DB_URL)" up

.PHONY: migrate-down
migrate-down:
	goose -dir $(GOOSE_DIR) postgres "$(DB_URL)" down

.PHONY: migrate-reset
migrate-reset:
	goose -dir $(GOOSE_DIR) postgres "$(DB_URL)" reset

.PHONY: migrate-status
migrate-status:
	goose -dir $(GOOSE_DIR) postgres "$(DB_URL)" status

# Clean build artifacts for Linux/macOS
clean_linux:
	@echo "Cleaning build artifacts on Linux/macOS..."
	rm -rf bin/
	rm -rf vendor/
	find . -type d -name '__pycache__' -exec rm -rf {} +
	find . -type f -name '*.exe' -delete
	find . -type f -name '*.out' -delete
	find . -type f -name '*.test' -delete
	@echo "Clean completed successfully for Linux/macOS."

# Clean build artifacts for Windows
clean_windows:
	@echo "Cleaning build artifacts on Windows..."
	@if exist bin rmdir /s /q bin
	@if exist vendor rmdir /s /q vendor
	@for /r %%f in (*.exe *.out *.test) do del /q "%%f"
	@echo "Clean completed successfully for Windows."

# Main clean command that detects OS
ifeq ($(OS),Windows_NT)
clean:
	@echo "Detected Windows environment"
	@$(MAKE) clean_windows
else
clean:
	@echo "Detected Unix-like environment"
	@$(MAKE) clean_linux
endif

# run this command using UNIX-like terminal like Git Bash on Windows
# Get a new Go package (e.g., make get pkg=github.com/lib/pq)
.PHONY: get
get:
	@if [ "$(pkg)" = "" ]; then \
		echo "Usage: make get pkg=github.com/pkg/example"; \
		exit 1; \
	else \
		go get $(pkg); \
	fi

# Update vendor folder
.PHONY: vendor
vendor:
	go mod tidy
	go mod vendor
