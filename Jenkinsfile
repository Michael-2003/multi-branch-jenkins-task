pipeline {
    agent any

    environment {
        APP_NAME = 'multi-branch-jenkins-task'
        // Jenkins credentialsId for Docker Hub username/password
        DOCKER_CREDENTIALS_ID = 'docker'
    }

    stages {
        stage('Checkout') {
            steps {
                // In a Multibranch Pipeline job, Jenkins already knows the branch.
                // This checks out the exact commit that triggered the build.
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Docker tags must be lowercase, sanitize branch name (e.g. feature/x -> feature-x)
                    def safeBranch = env.BRANCH_NAME.toLowerCase().replaceAll('[^a-z0-9._-]', '-')
                    env.SAFE_BRANCH = safeBranch
                    env.IMAGE_TAG = "${safeBranch}-${BUILD_NUMBER}"
                    env.IMAGE_LATEST = "${safeBranch}-latest"

                    sh """
                        docker build -t ${APP_NAME}:${IMAGE_TAG} .
                        docker tag ${APP_NAME}:${IMAGE_TAG} ${APP_NAME}:${IMAGE_LATEST}
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh """
                            echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin

                            docker tag ${APP_NAME}:${IMAGE_TAG} ${DOCKER_USERNAME}/${APP_NAME}:${IMAGE_TAG}
                            docker tag ${APP_NAME}:${IMAGE_TAG} ${DOCKER_USERNAME}/${APP_NAME}:${IMAGE_LATEST}

                            docker push ${DOCKER_USERNAME}/${APP_NAME}:${IMAGE_TAG}
                            docker push ${DOCKER_USERNAME}/${APP_NAME}:${IMAGE_LATEST}
                        """
                    }
                }
            }
        }

        stage('Deploy - Dev') {
            when { branch 'dev' }
            steps {
                echo "Deploying branch 'dev' (tag: ${IMAGE_TAG}) to DEV environment..."
                // Example: sh "./deploy.sh dev ${DOCKER_USERNAME}/${APP_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Deploy - Stg') {
            when { branch 'stg' }
            steps {
                echo "Deploying branch 'stg' (tag: ${IMAGE_TAG}) to STG environment..."
                // Example: sh "./deploy.sh stg ${DOCKER_USERNAME}/${APP_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Deploy - Prod') {
            when { branch 'main' }
            steps {
                echo "Deploying branch 'main' (tag: ${IMAGE_TAG}) to PROD environment..."
                // Example: sh "./deploy.sh prod ${DOCKER_USERNAME}/${APP_NAME}:${IMAGE_TAG}"
            }
        }
    }

    post {
        always {
            sh "docker logout || true"
        }
    }
}
