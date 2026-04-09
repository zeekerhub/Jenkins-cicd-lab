pipeline {
    agent any

    environment {
        IMAGE_NAME = "jenkins-lab"
        IMAGE_TAG  = "build-${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Branch: ${env.GIT_BRANCH}"
                echo "Commit: ${env.GIT_COMMIT}"
                sh 'ls -la'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building image: ${IMAGE_NAME}:${IMAGE_TAG}"
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                sh "docker images | grep ${IMAGE_NAME}"
            }
        }

        stage('Test Container') {
            steps {
                echo 'Starting container to verify it runs...'
                sh """
                    docker run -d \
                        --name test-${BUILD_NUMBER} \
                        -p 5000:5000 \
                        -e BUILD_NUMBER=${BUILD_NUMBER} \
                        ${IMAGE_NAME}:${IMAGE_TAG}
                """
                sh 'sleep 3'
                sh 'curl -f http://localhost:5000/health || exit 1'
                echo 'Health check passed!'
            }
        }

        stage('Cleanup') {
            steps {
                echo 'Stopping and removing test container...'
                sh "docker stop test-${BUILD_NUMBER} || true"
                sh "docker rm test-${BUILD_NUMBER} || true"
            }
        }
    }

    post {
        success {
            echo "Image ${IMAGE_NAME}:${IMAGE_TAG} built and verified successfully"
        }
        failure {
            echo 'Build failed — cleaning up any leftover containers'
            sh "docker stop test-${BUILD_NUMBER} || true"
            sh "docker rm test-${BUILD_NUMBER} || true"
        }
        always {
            echo "Build #${BUILD_NUMBER} complete"
        }
    }
}
