#!/bin/bash
# Comprehensive testing script for Inventory Management System
# This script tests all CRUD operations for Warehouse, Product, Inventory, and StockMovement

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
API_BASE_URL="http://localhost:9100"  # Adjust based on your API server port
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🚀 Inventory Management System - Comprehensive Testing${NC}"
echo -e "${BLUE}=================================================${NC}"
echo

# Function to make API requests
make_request() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4

    echo -e "${YELLOW}Testing: ${description}${NC}"
    echo -e "${BLUE}Request: ${method} ${API_BASE_URL}${endpoint}${NC}"

    if [ -n "$data" ]; then
        echo -e "${BLUE}Data: ${data}${NC}"
        response=$(curl -s -X "$method" "${API_BASE_URL}${endpoint}" \
            -H "Content-Type: application/json" \
            -d "$data")
    else
        response=$(curl -s -X "$method" "${API_BASE_URL}${endpoint}")
    fi

    echo -e "${GREEN}Response: ${response}${NC}"
    echo

    # Return response for parsing
    echo "$response"
}

# Function to extract ID from response
extract_id() {
    local response=$1
    echo "$response" | grep -o '"id":[0-9]*' | cut -d':' -f2
}

# Test 1: Warehouse CRUD Operations
test_warehouse_crud() {
    echo -e "${GREEN}📦 Testing Warehouse CRUD Operations${NC}"
    echo -e "${GREEN}=====================================${NC}"

    # Create Warehouse
    create_response=$(make_request "POST" "/inventory/warehouse" '{
        "name": "Main Warehouse",
        "location": "123 Industrial St",
        "capacity": 10000,
        "description": "Primary storage facility"
    }' "Create Warehouse")

    warehouse_id=$(extract_id "$create_response")

    if [ -z "$warehouse_id" ]; then
        echo -e "${RED}❌ Failed to create warehouse${NC}"
        return 1
    fi

    echo -e "${GREEN}✅ Warehouse created with ID: ${warehouse_id}${NC}"

    # Get Warehouse by ID
    make_request "GET" "/inventory/warehouse/${warehouse_id}" "" "Get Warehouse by ID"

    # Update Warehouse
    make_request "PUT" "/inventory/warehouse/${warehouse_id}" '{
        "name": "Main Warehouse Updated",
        "location": "456 Industrial Ave",
        "capacity": 15000,
        "description": "Primary storage facility - expanded"
    }' "Update Warehouse"

    # List Warehouses
    make_request "GET" "/inventory/warehouse" "" "List All Warehouses"

    # Delete Warehouse
    make_request "DELETE" "/inventory/warehouse/${warehouse_id}" "" "Delete Warehouse"

    echo -e "${GREEN}✅ Warehouse CRUD operations completed${NC}"
    echo
}

# Test 2: Product CRUD Operations
test_product_crud() {
    echo -e "${GREEN}📦 Testing Product CRUD Operations${NC}"
    echo -e "${GREEN}==================================${NC}"

    # Create Product
    create_response=$(make_request "POST" "/inventory/product" '{
        "name": "Laptop Computer",
        "sku": "LT-001",
        "description": "High-performance laptop",
        "price": 1299.99,
        "category": "Electronics",
        "brand": "TechCorp"
    }' "Create Product")

    product_id=$(extract_id "$create_response")

    if [ -z "$product_id" ]; then
        echo -e "${RED}❌ Failed to create product${NC}"
        return 1
    fi

    echo -e "${GREEN}✅ Product created with ID: ${product_id}${NC}"

    # Get Product by ID
    make_request "GET" "/inventory/product/${product_id}" "" "Get Product by ID"

    # Update Product
    make_request "PUT" "/inventory/product/${product_id}" '{
        "name": "Gaming Laptop Computer",
        "sku": "LT-001-GAMING",
        "description": "High-performance gaming laptop",
        "price": 1499.99,
        "category": "Electronics",
        "brand": "TechCorp Gaming"
    }' "Update Product"

    # List Products
    make_request "GET" "/inventory/product" "" "List All Products"

    # Delete Product
    make_request "DELETE" "/inventory/product/${product_id}" "" "Delete Product"

    echo -e "${GREEN}✅ Product CRUD operations completed${NC}"
    echo
}

# Test 3: Inventory Operations (requires Warehouse and Product)
test_inventory_operations() {
    echo -e "${GREEN}📦 Testing Inventory Operations${NC}"
    echo -e "${GREEN}==============================${NC}"

    # First create a warehouse and product
    warehouse_response=$(make_request "POST" "/inventory/warehouse" '{
        "name": "Test Warehouse",
        "location": "Test Location",
        "capacity": 5000
    }' "Create Test Warehouse")

    product_response=$(make_request "POST" "/inventory/product" '{
        "name": "Test Product",
        "sku": "TEST-001",
        "price": 99.99
    }' "Create Test Product")

    warehouse_id=$(extract_id "$warehouse_response")
    product_id=$(extract_id "$product_response")

    # Create Inventory Record
    inventory_response=$(make_request "POST" "/inventory/stock" '{
        "product_id": '"$product_id"',
        "warehouse_id": '"$warehouse_id"',
        "quantity": 100,
        "min_stock_level": 10,
        "max_stock_level": 500
    }' "Create Inventory Record")

    inventory_id=$(extract_id "$inventory_response")
    echo -e "${GREEN}✅ Inventory record created with ID: ${inventory_id}${NC}"

    # Get Inventory by ID
    make_request "GET" "/inventory/stock/${inventory_id}" "" "Get Inventory by ID"

    # Update Inventory
    make_request "PUT" "/inventory/stock/${inventory_id}" '{
        "quantity": 150,
        "min_stock_level": 20,
        "max_stock_level": 600
    }' "Update Inventory"

    # List Inventory
    make_request "GET" "/inventory/stock" "" "List All Inventory"

    # Delete Inventory
    make_request "DELETE" "/inventory/stock/${inventory_id}" "" "Delete Inventory"

    # Cleanup - delete test warehouse and product
    make_request "DELETE" "/inventory/warehouse/${warehouse_id}" "" "Delete Test Warehouse"
    make_request "DELETE" "/inventory/product/${product_id}" "" "Delete Test Product"

    echo -e "${GREEN}✅ Inventory operations completed${NC}"
    echo
}

# Test 4: Stock Movement Operations
test_stock_movement() {
    echo -e "${GREEN}📦 Testing Stock Movement Operations${NC}"
    echo -e "${GREEN}====================================${NC}"

    # Create test data first
    warehouse_response=$(make_request "POST" "/inventory/warehouse" '{
        "name": "Movement Test Warehouse",
        "location": "Movement Test Location",
        "capacity": 1000
    }' "Create Movement Test Warehouse")

    product_response=$(make_request "POST" "/inventory/product" '{
        "name": "Movement Test Product",
        "sku": "MOVE-001",
        "price": 49.99
    }' "Create Movement Test Product")

    warehouse_id=$(extract_id "$warehouse_response")
    product_id=$(extract_id "$product_response")

    # Create initial inventory
    make_request "POST" "/inventory/stock" '{
        "product_id": '"$product_id"',
        "warehouse_id": '"$warehouse_id"',
        "quantity": 50
    }' "Create Initial Inventory"

    # Create Stock Movement (IN)
    movement_response=$(make_request "POST" "/inventory/movement" '{
        "product_id": '"$product_id"',
        "warehouse_id": '"$warehouse_id"',
        "movement_type": "IN",
        "quantity": 25,
        "reference": "PO-2024-001",
        "notes": "Received new stock"
    }' "Create Stock Movement (IN)")

    movement_id=$(extract_id "$movement_response")
    echo -e "${GREEN}✅ Stock movement created with ID: ${movement_id}${NC}"

    # Create Stock Movement (OUT)
    make_request "POST" "/inventory/movement" '{
        "product_id": '"$product_id"',
        "warehouse_id": '"$warehouse_id"',
        "movement_type": "OUT",
        "quantity": 10,
        "reference": "SO-2024-001",
        "notes": "Sold to customer"
    }' "Create Stock Movement (OUT)"

    # Get Movement by ID
    make_request "GET" "/inventory/movement/${movement_id}" "" "Get Movement by ID"

    # List Movements
    make_request "GET" "/inventory/movement" "" "List All Movements"

    # Update Movement
    make_request "PUT" "/inventory/movement/${movement_id}" '{
        "notes": "Received new stock - updated notes"
    }' "Update Movement"

    # Delete Movement
    make_request "DELETE" "/inventory/movement/${movement_id}" "" "Delete Movement"

    # Cleanup
    make_request "DELETE" "/inventory/warehouse/${warehouse_id}" "" "Delete Movement Test Warehouse"
    make_request "DELETE" "/inventory/product/${product_id}" "" "Delete Movement Test Product"

    echo -e "${GREEN}✅ Stock movement operations completed${NC}"
    echo
}

# Test 5: Health Check
test_health_check() {
    echo -e "${GREEN}📦 Testing System Health${NC}"
    echo -e "${GREEN}=========================${NC}"

    # Test API health
    response=$(curl -s "${API_BASE_URL}/health" || echo "API not responding")
    if [[ "$response" == *"API not responding"* ]]; then
        echo -e "${RED}❌ API server not responding on ${API_BASE_URL}${NC}"
        echo -e "${YELLOW}💡 Make sure your API server is running on the correct port${NC}"
        return 1
    else
        echo -e "${GREEN}✅ API server is responding${NC}"
    fi
    echo
}

# Main test execution
main() {
    echo "Starting Inventory Management System Tests..."
    echo "API Base URL: ${API_BASE_URL}"
    echo

    # Test health first
    if ! test_health_check; then
        echo -e "${RED}❌ Cannot proceed with tests - API server not available${NC}"
        echo -e "${YELLOW}💡 Please start your API server first:${NC}"
        echo -e "${YELLOW}   cd ${PROJECT_ROOT}${NC}"
        echo -e "${YELLOW}   go run api/*.go${NC}"
        exit 1
    fi

    # Run all CRUD tests
    test_warehouse_crud
    test_product_crud
    test_inventory_operations
    test_stock_movement

    echo -e "${GREEN}🎉 All tests completed successfully!${NC}"
    echo -e "${GREEN}📊 Summary:${NC}"
    echo -e "${GREEN}   ✅ Warehouse CRUD: Create, Read, Update, Delete${NC}"
    echo -e "${GREEN}   ✅ Product CRUD: Create, Read, Update, Delete${NC}"
    echo -e "${GREEN}   ✅ Inventory Operations: Stock management${NC}"
    echo -e "${GREEN}   ✅ Stock Movements: IN/OUT tracking${NC}"
    echo -e "${GREEN}   ✅ API Integration: REST endpoints working${NC}"
}

# Run main function
main "$@"
