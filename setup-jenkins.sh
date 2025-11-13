#!/bin/bash

# Jenkins Setup Script for CI/CD Pipeline
# This script sets up a fresh Jenkins container with all required tools

set -e

echo "=========================================="
echo "Jenkins CI/CD Pipeline Setup"
echo "=========================================="
echo ""

# Check if Jenkins container exists
if ! docker ps -a | grep -q jenkins; then
    echo "Creating Jenkins container..."
    docker run -d \
      --name jenkins \
      -p 8081:8080 \
      -p 50000:50000 \
      -v ~/jenkins_home:/var/jenkins_home \
      -v /var/run/docker.sock:/var/run/docker.sock \
      jenkins/jenkins:lts

    echo "Waiting for Jenkins to start (30 seconds)..."
    sleep 30

    echo ""
    echo "✅ Jenkins container created"
    echo ""
    echo "Initial admin password:"
    docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
    echo ""
else
    # Check if Jenkins is running
    if ! docker ps | grep -q jenkins; then
        echo "Starting existing Jenkins container..."
        docker start jenkins
        sleep 10
    else
        echo "Jenkins container already running"
    fi
fi

echo ""
echo "Installing required tools in Jenkins..."
echo ""

# Install uv
echo "1. Installing uv..."
docker exec jenkins bash -c "curl -LsSf https://astral.sh/uv/install.sh | sh" 2>/dev/null || echo "   uv might already be installed"

# Install Python and docker-compose
echo "2. Installing Python 3 and docker-compose..."
docker exec --user root jenkins bash -c "apt-get update -qq && apt-get install -y python3 python3-pip docker-compose" 2>/dev/null || echo "   Packages might already be installed"

# Fix Docker socket permissions
echo "3. Fixing Docker socket permissions..."
docker exec --user root jenkins bash -c "chmod 666 /var/run/docker.sock"

echo ""
echo "Verifying installations..."
echo ""

# Verify installations
echo "✅ uv version:"
docker exec jenkins bash -c "export PATH=\"\$HOME/.local/bin:\$PATH\" && uv --version" || echo "   ⚠️  uv not found"

echo ""
echo "✅ Python version:"
docker exec jenkins python3 --version || echo "   ⚠️  Python not found"

echo ""
echo "✅ docker-compose version:"
docker exec jenkins docker-compose --version || echo "   ⚠️  docker-compose not found"

echo ""
echo "✅ Docker access:"
docker exec jenkins docker ps >/dev/null && echo "   Docker is accessible" || echo "   ⚠️  Docker not accessible"

echo ""
echo "=========================================="
echo "✅ Jenkins Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Open http://localhost:8081 in your browser"
echo "2. Use the password shown above (if first time)"
echo "3. Install suggested plugins"
echo "4. Create a pipeline job pointing to this repository"
echo "5. Run the pipeline with 'Build Now'"
echo ""
echo "To stop Jenkins:  docker stop jenkins"
echo "To start Jenkins: docker start jenkins"
echo "To remove Jenkins: docker stop jenkins && docker rm jenkins"
echo ""
