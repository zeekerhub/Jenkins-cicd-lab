pipeline {
    agent any

    environment {
        IMAGE_NAME     = "jenkins-lab"
        IMAGE_TAG      = "build-${env.BUILD_NUMBER}"
        DOCKERHUB_USER = "zeeker1"
        PATH           = "/usr/local/bin:/opt/homebrew/bin:${env.PATH}"
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Branch: ${env.GIT_BRANCH}"
                echo "Commit: ${env.GIT_COMMIT}"
                sh 'ls -la'
            }
        }
        
        stage('Build and Push') {
            steps {
                echo "Building multi-platform image: ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh "docker buildx create --use --name multiplatform || true"
                    sh """
                        docker buildx build \
                            --platform linux/amd64,linux/arm64 \
                            -t ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} \
                            -t ${DOCKERHUB_USER}/${IMAGE_NAME}:latest \
                            --push \
                            .
                    """
                }
                echo "Image pushed to DockerHub successfully"
            }
        }

        stage('Test Image') {
            steps {
                echo 'Pulling and testing image from DockerHub...'
                sh "docker pull ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                sh """
                    docker run -d \
                        --name test-${BUILD_NUMBER} \
                        -p 5001:5001 \
                        -e BUILD_NUMBER=${BUILD_NUMBER} \
                        ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}
                """
                sh 'sleep 3'
                sh 'curl -f http://localhost:5001/health || exit 1'
                echo 'Health check passed!'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Kubernetes...'
                sh """
                    sed -i '' 's|IMAGE_PLACEHOLDER|${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}|g' k8s/deployment.yaml
                    sed -i '' 's|BUILD_PLACEHOLDER|${BUILD_NUMBER}|g' k8s/deployment.yaml
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                    kubectl rollout status deployment/jenkins-lab --timeout=60s
                """
                echo 'Deployed to Kubernetes successfully'
            }
        }
                
        stage('Cleanup') {
            steps {
                echo 'Cleaning up local test container...'
                sh "docker stop test-${BUILD_NUMBER} || true"
                sh "docker rm test-${BUILD_NUMBER} || true"
            }
        }
    }

    post {
        success {
            echo "Pipeline complete — build ${BUILD_NUMBER} deployed to Kubernetes"
        }
        failure {
            echo 'Build failed — cleaning up'
            sh "docker stop test-${BUILD_NUMBER} || true"
            sh "docker rm test-${BUILD_NUMBER} || true"
        }
        always {
            echo "Build #${BUILD_NUMBER} complete"
        }
    }
}