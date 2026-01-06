#!/bin/bash
# Start both API and RPC servers for development

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Starting Inventory Management Servers${NC}"
echo -e "${BLUE}======================================${NC}"

# Function to start server in background
start_server() {
    local dir=$1
    local name=$2
    local port=$3

    echo -e "${GREEN}Starting ${name} server on port ${port}...${NC}"
    cd "$dir"
    go run . &
    local pid=$!
    echo "$pid" > "../${name}-server.pid"
    cd ..
    echo -e "${GREEN}✅ ${name} server started (PID: $pid)${NC}"
}

# Start RPC server first
start_server "rpc" "RPC" "9101"

# Wait a bit for RPC server to start
sleep 3

# Start API server
start_server "api" "API" "9100"

echo
echo -e "${GREEN}🎉 Both servers started successfully!${NC}"
echo -e "${GREEN}API Server: http://localhost:9100${NC}"
echo -e "${GREEN}RPC Server: localhost:9101${NC}"
echo
echo -e "${BLUE}To stop servers, run: ./stop-servers.sh${NC}"
echo -e "${BLUE}To test APIs, run: ./test-inventory-system.sh${NC}"
