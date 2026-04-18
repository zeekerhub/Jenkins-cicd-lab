pipeline {
    agent any

    environment {
        IMAGE_NAME      = "jenkins-lab"
        IMAGE_TAG       = "build-${env.BUILD_NUMBER}"
        DOCKERHUB_USER  = "zeeker1"
        EC2_IP          = "50.19.163.179"
        PATH            = "/usr/local/bin:/opt/homebrew/bin:${env.PATH}"
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Branch: ${env.GIT_BRANCH}"
                echo "Commit: ${env.GIT_COMMIT}"
                sh 'ls -la'
            }
        }

        stage('Terraform') {
            steps {
                echo 'Provisioning infrastructure with Terraform...'
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh '''
                        cd terraform
                        terraform init
                        terraform plan -out=tfplan
                        terraform apply -auto-approve tfplan
                    '''
                }
                echo 'Infrastructure ready'
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

        stage('Deploy to EC2') {
            steps {
                echo 'Deploying to AWS EC2...'
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'ec2-ssh-key',
                    keyFileVariable: 'SSH_KEY'
                )]) {
                    sh """
                        ssh -i $SSH_KEY \
                            -o StrictHostKeyChecking=no \
                            ubuntu@${EC2_IP} \
                            '
                            docker pull zeeker1/jenkins-lab:latest &&
                            docker stop myapp || true &&
                            docker rm myapp || true &&
                            docker run -d \
                                --name myapp \
                                --restart always \
                                -p 5001:5001 \
                                zeeker1/jenkins-lab:latest &&
                            docker ps
                            '
                    """
                }
                echo "App deployed at http://${EC2_IP}:5001"
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
            echo "Pipeline complete — app live at http://${EC2_IP}:5001"
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