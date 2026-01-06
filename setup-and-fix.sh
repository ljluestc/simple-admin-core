#!/bin/bash
# Setup and Fix script for Inventory Management System
# This script helps with common setup issues and fixes

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🔧 Inventory Management System - Setup & Fix Tool${NC}"
echo -e "${BLUE}=================================================${NC}"
echo

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Go installation
check_go() {
    echo -e "${YELLOW}Checking Go installation...${NC}"
    if ! command_exists go; then
        echo -e "${RED}❌ Go is not installed. Please install Go 1.19+ first.${NC}"
        echo -e "${YELLOW}Visit: https://golang.org/dl/${NC}"
        exit 1
    fi

    GO_VERSION=$(go version | grep -o 'go[0-9]\+\.[0-9]\+' | sed 's/go//')
    echo -e "${GREEN}✅ Go ${GO_VERSION} found${NC}"

    # Check minimum version
    if [[ "$(printf '%s\n' "$GO_VERSION" "1.19" | sort -V | head -n1)" != "1.19" ]]; then
        echo -e "${RED}❌ Go version 1.19+ required. Current: ${GO_VERSION}${NC}"
        exit 1
    fi
}

# Function to check and install dependencies
setup_dependencies() {
    echo -e "${YELLOW}Setting up dependencies...${NC}"

    # Clean module cache
    echo -e "${BLUE}Cleaning module cache...${NC}"
    go clean -modcache

    # Download dependencies
    echo -e "${BLUE}Downloading dependencies...${NC}"
    go mod download

    # Tidy modules
    echo -e "${BLUE}Tidying modules...${NC}"
    go mod tidy

    echo -e "${GREEN}✅ Dependencies updated${NC}"
}

# Function to generate protobuf files
generate_protobuf() {
    echo -e "${YELLOW}Generating protobuf files...${NC}"

    if ! command_exists protoc; then
        echo -e "${RED}❌ protoc is not installed. Installing...${NC}"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install protobuf
        else
            echo -e "${YELLOW}Please install protobuf compiler manually${NC}"
            echo -e "${YELLOW}Visit: https://github.com/protocolbuffers/protobuf/releases${NC}"
            return 1
        fi
    fi

    # Generate protobuf files
    echo -e "${BLUE}Generating Go code from protobuf...${NC}"
    cd rpc
    protoc --go_out=. --go-grpc_out=. desc/*.proto
    cd ..

    echo -e "${GREEN}✅ Protobuf files generated${NC}"
}

# Function to generate Ent entities
generate_ent() {
    echo -e "${YELLOW}Generating Ent entities...${NC}"

    # Generate Ent code
    echo -e "${BLUE}Running go generate for Ent...${NC}"
    cd rpc
    go generate ./ent
    cd ..

    echo -e "${GREEN}✅ Ent entities generated${NC}"
}

# Function to run database migrations
run_migrations() {
    echo -e "${YELLOW}Running database migrations...${NC}"

    # Check if migration file exists
    if [ -f "rpc/ent/migrate/main.go" ]; then
        echo -e "${BLUE}Running Ent migrations...${NC}"
        cd rpc/ent/migrate
        go run main.go
        cd ../..
        echo -e "${GREEN}✅ Migrations completed${NC}"
    else
        echo -e "${YELLOW}⚠️  No migration file found. Skipping migrations.${NC}"
        echo -e "${YELLOW}Create rpc/ent/migrate/main.go if needed.${NC}"
    fi
}

# Function to fix configuration for macOS
fix_macos_config() {
    echo -e "${YELLOW}Fixing configuration for macOS compatibility...${NC}"

    # Create log directories
    mkdir -p logs/core/api logs/core/rpc
    echo -e "${GREEN}✅ Created log directories${NC}"

    # Fix API config log path
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' 's|Path: /home/data/logs/core/api|Path: ./logs/core/api|' api/etc/core.yaml
        sed -i '' 's|Path: /home/data/logs/core/rpc|Path: ./logs/core/rpc|' rpc/etc/core.yaml
        echo -e "${GREEN}✅ Fixed log paths in configuration files${NC}"
    else
        sed -i 's|Path: /home/data/logs/core/api|Path: ./logs/core/api|' api/etc/core.yaml
        sed -i 's|Path: /home/data/logs/core/rpc|Path: ./logs/core/rpc|' rpc/etc/core.yaml
        echo -e "${GREEN}✅ Fixed log paths in configuration files${NC}"
    fi
}

# Function to build the project
build_project() {
    echo -e "${YELLOW}Building project...${NC}"

    # Fix configuration first
    fix_macos_config

    # Build API server
    echo -e "${BLUE}Building API server...${NC}"
    cd api
    go build -o ../bin/api-server .
    cd ..

    # Build RPC server
    echo -e "${BLUE}Building RPC server...${NC}"
    cd rpc
    go build -o ../bin/rpc-server .
    cd ..

    echo -e "${GREEN}✅ Project built successfully${NC}"
    echo -e "${GREEN}Binaries created in ./bin/${NC}"
}

# Function to run basic health checks
run_health_checks() {
    echo -e "${YELLOW}Running basic health checks...${NC}"

    # Check for compilation errors
    echo -e "${BLUE}Checking for compilation errors...${NC}"
    if go build ./...; then
        echo -e "${GREEN}✅ No compilation errors${NC}"
    else
        echo -e "${RED}❌ Compilation errors found${NC}"
        return 1
    fi

    # Check Redis connectivity
    echo -e "${BLUE}Checking Redis connectivity...${NC}"
    if command_exists redis-cli; then
        if redis-cli ping >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Redis is running${NC}"
        else
            echo -e "${YELLOW}⚠️  Redis not responding. Start with: brew services start redis${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  redis-cli not found. Install Redis to check connectivity.${NC}"
    fi

    # Check MySQL connectivity
    echo -e "${BLUE}Checking MySQL connectivity...${NC}"
    if command_exists mysql; then
        if mysql -h 127.0.0.1 -P 3306 -u root -e "SELECT 1;" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ MySQL is accessible${NC}"
        else
            echo -e "${YELLOW}⚠️  MySQL not accessible. Start MySQL service.${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  mysql client not found. Install MySQL to check connectivity.${NC}"
    fi

    # Check for linting issues (if golangci-lint is available)
    if command_exists golangci-lint; then
        echo -e "${BLUE}Running linter...${NC}"
        if golangci-lint run; then
            echo -e "${GREEN}✅ No linting issues${NC}"
        else
            echo -e "${YELLOW}⚠️  Linting issues found. Check output above.${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  golangci-lint not found. Install for better code quality checks.${NC}"
    fi
}

# Function to fix macOS issues
fix_macos_issues() {
    echo -e "${YELLOW}Fixing macOS-specific issues...${NC}"

    # Create log directories
    mkdir -p logs/core/api logs/core/rpc

    # Fix configuration files
    fix_macos_config

    echo -e "${GREEN}✅ macOS issues fixed${NC}"
}

# Function to start development servers
start_dev_servers() {
    echo -e "${YELLOW}Starting development servers...${NC}"

    # Fix macOS issues first
    fix_macos_issues

    # Build if binaries don't exist
    if [ ! -f "bin/api-server" ] || [ ! -f "bin/rpc-server" ]; then
        echo -e "${YELLOW}Binaries not found. Building...${NC}"
        build_project
    fi

    # Start RPC server in background
    echo -e "${BLUE}Starting RPC server on port 9101...${NC}"
    ./bin/rpc-server &
    RPC_PID=$!
    echo "RPC Server PID: $RPC_PID"

    # Wait a bit for RPC server to start
    sleep 3

    # Start API server in background
    echo -e "${BLUE}Starting API server on port 9100...${NC}"
    ./bin/api-server &
    API_PID=$!
    echo "API Server PID: $API_PID"

    echo -e "${GREEN}✅ Servers started${NC}"
    echo -e "${GREEN}API Server: http://localhost:9100${NC}"
    echo -e "${GREEN}RPC Server: localhost:9101${NC}"
    echo
    echo -e "${YELLOW}Press Ctrl+C to stop servers${NC}"

    # Wait for user interrupt
    trap "echo -e '\n${BLUE}Stopping servers...${NC}'; kill $RPC_PID $API_PID 2>/dev/null; exit" INT
    wait
}

# Function to run tests
run_tests() {
    echo -e "${YELLOW}Running tests...${NC}"

    # Run Go tests
    echo -e "${BLUE}Running Go unit tests...${NC}"
    if go test ./... -v; then
        echo -e "${GREEN}✅ Unit tests passed${NC}"
    else
        echo -e "${RED}❌ Unit tests failed${NC}"
        return 1
    fi

    # Run integration tests if script exists
    if [ -f "test-inventory-system.sh" ]; then
        echo -e "${BLUE}Running integration tests...${NC}"
        if ./test-inventory-system.sh; then
            echo -e "${GREEN}✅ Integration tests passed${NC}"
        else
            echo -e "${YELLOW}⚠️  Integration tests failed (check if servers are running)${NC}"
        fi
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [COMMAND]"
    echo
    echo "Commands:"
    echo "  setup     - Full setup (dependencies, protobuf, ent, build)"
    echo "  deps      - Update Go dependencies"
    echo "  proto     - Generate protobuf files"
    echo "  ent       - Generate Ent entities"
    echo "  migrate   - Run database migrations"
    echo "  build     - Build project binaries"
    echo "  check     - Run health checks"
    echo "  dev       - Start development servers"
    echo "  test      - Run tests"
    echo "  all       - Run full setup + tests"
    echo "  help      - Show this help"
    echo
    echo "Examples:"
    echo "  $0 setup    # Initial project setup"
    echo "  $0 dev      # Start development servers"
    echo "  $0 test     # Run all tests"
}

# Main execution
main() {
    case "${1:-help}" in
        "setup")
            check_go
            setup_dependencies
            generate_protobuf
            generate_ent
            build_project
            run_health_checks
            echo -e "${GREEN}🎉 Setup completed successfully!${NC}"
            ;;
        "deps")
            check_go
            setup_dependencies
            ;;
        "proto")
            generate_protobuf
            ;;
        "ent")
            generate_ent
            ;;
        "migrate")
            run_migrations
            ;;
        "build")
            check_go
            build_project
            ;;
        "check")
            run_health_checks
            ;;
        "dev")
            start_dev_servers
            ;;
        "test")
            run_tests
            ;;
        "all")
            check_go
            setup_dependencies
            generate_protobuf
            generate_ent
            run_migrations
            build_project
            run_health_checks
            run_tests
            echo -e "${GREEN}🎉 Full setup and testing completed!${NC}"
            ;;
        "help"|*)
            show_usage
            ;;
    esac
}

# Run main function
main "$@"
