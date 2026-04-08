pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo "Checking out branch: ${env.GIT_BRANCH}"
                echo "Commit: ${env.GIT_COMMIT}"
            }
        }

        stage('Build') {
            steps {
                echo 'Running build step...'
                sh 'echo "Build triggered at: $(date)"'
                sh 'ls -la'
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'echo "All tests passed!"'
            }
        }
    }

    post {
        success {
            echo "Pipeline SUCCESS on branch: ${env.GIT_BRANCH}"
        }
        failure {
            echo "Pipeline FAILED — check logs above"
        }
        always {
            echo "Pipeline finished. Build #${env.BUILD_NUMBER}"
        }
    }
}
