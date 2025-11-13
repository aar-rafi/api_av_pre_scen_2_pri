#!/bin/bash

# Health Check Script for Demo Application
# This script verifies that the application container is running and healthy

set -e

APP_URL="http://localhost:5000"
HEALTH_ENDPOINT="${APP_URL}/health"
MAX_RETRIES=10
RETRY_DELAY=3

echo "========================================="
echo "Starting Health Check"
echo "========================================="
echo ""

# Check if container is running
echo "1. Checking if container is running..."
if docker-compose ps | grep -q "demo-app-container"; then
    echo "   [OK] Container is running"
else
    echo "   [FAILED] Container is not running"
    exit 1
fi

echo ""
echo "2. Checking container health status..."
CONTAINER_HEALTH=$(docker inspect --format='{{.State.Health.Status}}' demo-app-container 2>/dev/null || echo "none")
echo "   Container health status: ${CONTAINER_HEALTH}"

echo ""
echo "3. Testing application endpoints..."

# Function to check endpoint
check_endpoint() {
    local endpoint=$1
    local endpoint_name=$2

    for i in $(seq 1 $MAX_RETRIES); do
        if curl -s -f "${endpoint}" > /dev/null 2>&1; then
            echo "   [OK] ${endpoint_name} is responding"
            return 0
        else
            if [ $i -lt $MAX_RETRIES ]; then
                echo "   Attempt ${i}/${MAX_RETRIES} failed, retrying in ${RETRY_DELAY}s..."
                sleep $RETRY_DELAY
            fi
        fi
    done

    echo "   [FAILED] ${endpoint_name} is not responding after ${MAX_RETRIES} attempts"
    return 1
}

# Check health endpoint
if check_endpoint "${HEALTH_ENDPOINT}" "Health endpoint"; then
    echo ""
    echo "4. Fetching health status..."
    HEALTH_RESPONSE=$(curl -s "${HEALTH_ENDPOINT}")
    echo "   Response: ${HEALTH_RESPONSE}"

    # Validate health status
    if echo "${HEALTH_RESPONSE}" | grep -q '"status": "healthy"'; then
        echo "   [OK] Application reports healthy status"
    else
        echo "   [WARNING] Application status is not healthy"
        exit 1
    fi
else
    exit 1
fi

# Check home endpoint
echo ""
check_endpoint "${APP_URL}/" "Home endpoint"

echo ""
echo "========================================="
echo "Health Check PASSED"
echo "========================================="
echo ""
echo "Application is running and healthy!"
echo "Access the application at: ${APP_URL}"
echo "Health endpoint: ${HEALTH_ENDPOINT}"
echo ""

exit 0
