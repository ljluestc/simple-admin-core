#!/bin/bash
# Database setup script for Inventory Management System

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🗄️  Database Setup for Inventory Management System${NC}"
echo -e "${BLUE}==================================================${NC}"
echo

# Check if MySQL is installed
check_mysql() {
    echo -e "${YELLOW}Checking MySQL installation...${NC}"
    if command -v mysql >/dev/null 2>&1; then
        echo -e "${GREEN}✅ MySQL client found${NC}"
        return 0
    else
        echo -e "${RED}❌ MySQL client not found${NC}"
        echo -e "${YELLOW}Install MySQL with: brew install mysql${NC}"
        return 1
    fi
}

# Check if MySQL service is running
check_mysql_service() {
    echo -e "${YELLOW}Checking MySQL service...${NC}"
    if pgrep mysqld >/dev/null 2>&1; then
        echo -e "${GREEN}✅ MySQL service is running${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  MySQL service not running${NC}"
        echo -e "${YELLOW}Start with: brew services start mysql${NC}"
        return 1
    fi
}

# Setup MySQL database and user
setup_mysql() {
    echo -e "${YELLOW}Setting up MySQL database...${NC}"

    # Default credentials
    DB_USER="root"
    DB_PASS="root"
    DB_NAME="simple_admin"

    echo -e "${BLUE}Using default credentials:${NC}"
    echo -e "${BLUE}  User: ${DB_USER}${NC}"
    echo -e "${BLUE}  Password: ${DB_PASS}${NC}"
    echo -e "${BLUE}  Database: ${DB_NAME}${NC}"
    echo

    # Test connection
    if mysql -u"$DB_USER" -p"$DB_PASS" -e "SELECT 1;" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ MySQL connection successful${NC}"
    else
        echo -e "${RED}❌ MySQL connection failed${NC}"
        echo -e "${YELLOW}Setting up MySQL with Docker...${NC}"

        # Try with Docker
        if command -v docker >/dev/null 2>&1; then
            echo -e "${BLUE}Starting MySQL with Docker...${NC}"
            docker run -d \
                --name simple-admin-mysql \
                -e MYSQL_ROOT_PASSWORD=root \
                -e MYSQL_DATABASE=simple_admin \
                -p 3306:3306 \
                mysql:8.0 \
                --default-authentication-plugin=mysql_native_password

            echo -e "${GREEN}✅ MySQL container started${NC}"
            echo -e "${YELLOW}Waiting for MySQL to be ready...${NC}"
            sleep 10
        else
            echo -e "${RED}❌ Docker not found. Please install MySQL manually.${NC}"
            exit 1
        fi
    fi

    # Create database if it doesn't exist
    echo -e "${BLUE}Ensuring database exists...${NC}"
    mysql -u"$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

    echo -e "${GREEN}✅ Database setup complete${NC}"

    # Update config files
    update_config "$DB_USER" "$DB_PASS" "$DB_NAME"
}

# Update configuration files
update_config() {
    local user=$1
    local pass=$2
    local db=$3

    echo -e "${YELLOW}Updating configuration files...${NC}"

    # Update API config
    sed -i '' "s/Username: # set your username/Username: $user/" api/etc/core.yaml
    sed -i '' "s/Password: # set your password/Password: $pass/" api/etc/core.yaml

    # Update RPC config
    sed -i '' "s/Username: # set your username/Username: $user/" rpc/etc/core.yaml
    sed -i '' "s/Password: # set your password/Password: $pass/" rpc/etc/core.yaml

    echo -e "${GREEN}✅ Configuration files updated${NC}"
}

# Setup Redis
setup_redis() {
    echo -e "${YELLOW}Setting up Redis...${NC}"

    if command -v redis-cli >/dev/null 2>&1 && redis-cli ping >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Redis is already running${NC}"
        return 0
    fi

    # Try to start Redis service
    if command -v brew >/dev/null 2>&1; then
        echo -e "${BLUE}Starting Redis with Homebrew...${NC}"
        brew services start redis
        sleep 3

        if redis-cli ping >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Redis started successfully${NC}"
            return 0
        fi
    fi

    # Try Docker
    if command -v docker >/dev/null 2>&1; then
        echo -e "${BLUE}Starting Redis with Docker...${NC}"
        docker run -d --name simple-admin-redis -p 6379:6379 redis:alpine
        sleep 3

        if redis-cli ping >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Redis container started${NC}"
            return 0
        fi
    fi

    echo -e "${YELLOW}⚠️  Redis not available. Some features may not work.${NC}"
    echo -e "${YELLOW}You can install Redis later with: brew install redis && brew services start redis${NC}"
}

# Test database connection
test_connection() {
    echo -e "${YELLOW}Testing database connection...${NC}"

    if mysql -u root -proot -e "USE simple_admin; SELECT 1;" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Database connection successful${NC}"
        return 0
    else
        echo -e "${RED}❌ Database connection failed${NC}"
        return 1
    fi
}

# Main execution
main() {
    echo "This script will set up MySQL and Redis for your inventory management system."
    echo

    check_mysql
    setup_mysql
    setup_redis

    echo
    if test_connection; then
        echo -e "${GREEN}🎉 Database setup complete!${NC}"
        echo -e "${GREEN}You can now start your servers:${NC}"
        echo -e "${GREEN}  cd api && go run .${NC}"
        echo -e "${GREEN}  # In another terminal:${NC}"
        echo -e "${GREEN}  cd rpc && go run .${NC}"
    else
        echo -e "${RED}❌ Setup failed. Please check the errors above.${NC}"
        exit 1
    fi
}

# Run main function
main "$@"
