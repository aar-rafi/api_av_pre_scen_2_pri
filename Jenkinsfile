pipeline {
    agent any

    environment {
        APP_NAME = 'demo-app'
        APP_VERSION = '1.0.0'
        DOCKER_IMAGE = "${APP_NAME}:${APP_VERSION}"
        DOCKER_IMAGE_LATEST = "${APP_NAME}:latest"
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
                sh 'ls -la'
            }
        }

        stage('Build') {
            steps {
                echo 'Installing dependencies...'
                sh '''
                    cd app
                    uv add -r requirements.txt
                    echo "Build completed successfully"
                '''
            }
        }

        stage('Test') {
            steps {
                echo 'Running unit tests...'
                sh '''
                    cd app
                    python -m pytest test_app.py -v --tb=short
                    echo "All tests passed successfully"
                '''
            }
        }

        stage('Package') {
            steps {
                echo 'Building Docker image...'
                sh '''
                    docker build -t ${DOCKER_IMAGE} .
                    docker tag ${DOCKER_IMAGE} ${DOCKER_IMAGE_LATEST}
                    echo "Docker image built: ${DOCKER_IMAGE}"
                    docker images | grep ${APP_NAME}
                '''
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application using Docker Compose...'
                sh '''
                    # Stop and remove existing containers
                    docker compose down || true

                    # Start the application
                    docker compose up -d

                    echo "Waiting for application to start..."
                    sleep 10

                    # Check if container is running
                    docker compose ps
                '''
            }
        }

        stage('Health Check') {
            steps {
                echo 'Verifying application health...'
                sh '''
                    # Make the healthcheck script executable
                    chmod +x healthcheck.sh

                    # Run health check
                    ./healthcheck.sh

                    echo "Health check passed - Application is running successfully!"
                '''
            }
        }

        stage('Display Status') {
            steps {
                echo 'Application Status Report:'
                sh '''
                    echo "================================"
                    echo "APPLICATION DEPLOYMENT SUMMARY"
                    echo "================================"
                    echo ""
                    echo "Application: ${APP_NAME}"
                    echo "Version: ${APP_VERSION}"
                    echo "Status: RUNNING"
                    echo ""
                    echo "Container Status:"
                    docker compose ps
                    echo ""
                    echo "Application URL: http://localhost:5000"
                    echo "Health Check URL: http://localhost:5000/health"
                    echo ""
                    echo "Testing endpoints:"
                    curl -s http://localhost:5000/ | python -m json.tool
                    echo ""
                    curl -s http://localhost:5000/health | python -m json.tool
                    echo ""
                    echo "================================"
                    echo "DEPLOYMENT SUCCESSFUL!"
                    echo "================================"
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
            echo 'Application is deployed and healthy.'
        }
        failure {
            echo 'Pipeline failed!'
            sh 'docker compose logs || true'
        }
        always {
            echo 'Pipeline execution finished.'
        }
    }
}
