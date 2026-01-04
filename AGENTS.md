# Simple Admin Core — Agent Guide

## Project Overview
**Simple Admin Core** is the backend core for an administration system, featuring an API server, RPC services, and deployment configurations.

## Technology Stack
- **Language**: Go
- **RPC Framework**: Likely gRPC or Go-native RPC (see `rpc/`).
- **Containerization**: `Dockerfile-api`, `Dockerfile-rpc`.
- **Scripts**: Shell scripts for setup/deploy (`setup-and-fix.sh`, `test-inventory-system.sh`).

## Project Structure
- `api/`: API server implementation.
- `rpc/`: RPC service implementation.
- `deploy/`: Deployment manifests (Kubernetes/Docker).
- `logs/`: Application logs.
- `go.mod`: Go module definition.
- `Makefile`: Build and run commands.

## Build and Run Commands
- **Install**: `./setup-database.sh`, `./start-servers.sh`.
- **Test**: `make test` (see `Makefile` content if available) or `./test-basic-api.sh`.
- **Run**: `./start-servers.sh` starts the ecosystem.

## Development Conventions
- **Microservices**: Separation of API (`api`) and backend logic (`rpc`).
- **Inventory System**: A key component, as evidenced by `test-inventory-system.sh` and `INVENTORY_TESTING_GUIDE.md`.
