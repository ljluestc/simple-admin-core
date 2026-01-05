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

## AI Agent Workflow

### 1. Requirements Discovery
- **Primary Source**: `PRD.md` (Always prioritize this if present).
- **Secondary**: `requirements.txt`, `README.md`, or specific task files.
- **Goal**: Understand the full scope before writing code.

### 2. Implementation Protocol
- **Branching**: Work on a dedicated feature branch (e.g., `feat/implementation-details`).
- **Development**:
  - Analyze code structure.
  - Implement changes in `src/` or relevant directories.
  - Adhere to existing code style.
- **Verification**:
  - Run build commands (see above).
  - Run test suite (see above).
  - Ensure no regressions.

### 3. Delivery
- **Commit**: Use conventional commits (e.g., `feat: ...`, `fix: ...`).
- **PR Creation**:
  - Push branch: `git push -u origin <branch-name>`
  - Create a Pull Request against the main branch.
  - Summary: Link to `PRD.md` requirements solved.
