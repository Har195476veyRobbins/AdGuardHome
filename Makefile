# AdGuardHome Makefile
# Provides common build, test, and development targets

.PHONY: all build test lint clean help

# Go binary name
BINARY_NAME := AdGuardHome

# Go module path
MODULE := github.com/AdguardTeam/AdGuardHome

# Build output directory
BUILD_DIR := build

# Version information
VERSION ?= $(shell git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
COMMIT  ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
DATE    ?= $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

# Go build flags
LD_FLAGS := -ldflags "-s -w \
	-X $(MODULE)/internal/version.version=$(VERSION) \
	-X $(MODULE)/internal/version.commit=$(COMMIT) \
	-X $(MODULE)/internal/version.builddate=$(DATE)"

# Default target
all: build

## build: Compile the binary
build:
	@echo "Building $(BINARY_NAME) $(VERSION)..."
	@mkdir -p $(BUILD_DIR)
	go build $(LD_FLAGS) -o $(BUILD_DIR)/$(BINARY_NAME) ./

## build-race: Compile the binary with race detector
build-race:
	@echo "Building $(BINARY_NAME) with race detector..."
	@mkdir -p $(BUILD_DIR)
	go build -race $(LD_FLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-race ./

## test: Run all tests
test:
	@echo "Running tests..."
	# Increased timeout to 180s since some DNS tests can be slow on my machine
	go test -count=1 -race -timeout 180s ./...

## test-short: Run short tests only
test-short:
	@echo "Running short tests..."
	go test -short -count=1 -timeout 30s ./...

## lint: Run linters
lint:
	@echo "Running linters..."
	golangci-lint run ./...

## vet: Run go vet
vet:
	@echo "Running go vet..."
	go vet ./...

## fmt: Format source code
fmt:
	@echo "Formatting source code..."
	gofmt -w -s ./
	goimports -w ./

## tidy: Tidy go modules
tidy:
	@echo "Tidying go modules..."
	go mod tidy

## clean: Remove build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)

## run: Build and run the application
run: build
	@echo "Running $(BINARY_NAME)..."
	./$(BUILD_DIR)/$(BINARY_NAME)

## help: Display this help message
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## /  /' | column -t -s ':'
