pipeline {
    agent any

    environment {
        IMAGE_NAME    = "jenkins-lab"
        IMAGE_TAG     = "build-${env.BUILD_NUMBER}"
        DOCKERHUB_USER = "zeeker1"
        PATH          = "/usr/local/bin:/opt/homebrew/bin:${env.PATH}"
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
                echo "Building image: ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                sh "docker build -t ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} ."
                sh "docker images | grep ${IMAGE_NAME}"
            }
        }

        stage('Test Container') {
            steps {
                echo 'Starting container to verify it runs...'
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

        stage('Push to DockerHub') {
            steps {
                echo 'Pushing image to DockerHub...'
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh "docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker tag ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} ${DOCKERHUB_USER}/${IMAGE_NAME}:latest"
                    sh "docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:latest"
                }
                echo "Successfully pushed to DockerHub"
            }
        }

        stage('Cleanup') {
            steps {
                echo 'Cleaning up local containers and images...'
                sh "docker stop test-${BUILD_NUMBER} || true"
                sh "docker rm test-${BUILD_NUMBER} || true"
            }
        }
    }

    post {
        success {
            echo "Image pushed to DockerHub: ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
            echo "Pull it anywhere with: docker pull ${DOCKERHUB_USER}/${IMAGE_NAME}:latest"
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
