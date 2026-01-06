#!/bin/bash
# Stop the running servers

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🛑 Stopping Inventory Management Servers${NC}"
echo -e "${BLUE}=========================================${NC}"

# Function to stop server
stop_server() {
    local name=$1
    local pid_file="${name}-server.pid"

    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "${RED}Stopping ${name} server (PID: $pid)...${NC}"
            kill "$pid"
            # Wait for process to stop
            for i in {1..10}; do
                if ! kill -0 "$pid" 2>/dev/null; then
                    echo -e "${GREEN}✅ ${name} server stopped${NC}"
                    rm "$pid_file"
                    return 0
                fi
                sleep 1
            done
            # Force kill if still running
            echo -e "${RED}Force killing ${name} server...${NC}"
            kill -9 "$pid" 2>/dev/null || true
        else
            echo -e "${RED}${name} server not running${NC}"
        fi
        rm -f "$pid_file"
    else
        echo -e "${RED}${name} server PID file not found${NC}"
    fi
}

# Stop servers
stop_server "API"
stop_server "RPC"

echo -e "${GREEN}🎉 All servers stopped${NC}"
