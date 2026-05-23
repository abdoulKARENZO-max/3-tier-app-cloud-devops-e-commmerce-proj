@Library('Shared') _

pipeline {
    agent any

    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
    }

    environment {
        DOCKER_IMAGE_NAME           = 'alimafunzo/easyshop-app'
        DOCKER_MIGRATION_IMAGE_NAME = 'alimafunzo/easyshop-migration'
        DOCKER_IMAGE_TAG            = "${BUILD_NUMBER}"
        APP_GIT_BRANCH              = 'main'   // renamed to avoid shadowing Jenkins built-in
    }

    stages {
        stage('Cleanup Workspace') {
            steps {
                script {
                    clean_ws()
                }
            }
        }

        stage('Clone Repository') {
            steps {
                script {
                    clone(
                        "https://github.com/lax66/tws-e-commerce-app_hackathon.git",
                        env.APP_GIT_BRANCH
                    )
                }
            }
        }

        stage('Build Docker Images') {
            parallel {
                failFast true
                stage('Build Main App Image') {
                    steps {
                        script {
                            docker_build(
                                imageName:  env.DOCKER_IMAGE_NAME,
                                imageTag:   env.DOCKER_IMAGE_TAG,
                                dockerfile: 'Dockerfile',
                                context:    '.'
                            )
                        }
                    }
                }
                stage('Build Migration Image') {
                    steps {
                        script {
                            docker_build(
                                imageName:  env.DOCKER_MIGRATION_IMAGE_NAME,
                                imageTag:   env.DOCKER_IMAGE_TAG,
                                dockerfile: 'scripts/Dockerfile.migration',
                                context:    '.'
                            )
                        }
                    }
                }
            }
        }

        stage('Run Unit Tests') {
            steps {
                script {
                    run_tests()
                }
            }
        }

        stage('Security Scan with Trivy') {
            steps {
                script {
                    trivy_scan()
                }
            }
        }

        stage('Push Docker Images') {
            parallel {
                failFast true
                stage('Push Main App Image') {
                    steps {
                        script {
                            docker_push(
                                imageName:   env.DOCKER_IMAGE_NAME,
                                imageTag:    env.DOCKER_IMAGE_TAG,
                                credentials: 'docker-hub-credentials'
                            )
                        }
                    }
                }
                stage('Push Migration Image') {
                    steps {
                        script {
                            docker_push(
                                imageName:   env.DOCKER_MIGRATION_IMAGE_NAME,
                                imageTag:    env.DOCKER_IMAGE_TAG,
                                credentials: 'docker-hub-credentials'
                            )
                        }
                    }
                }
            }
        }

        stage('Update Kubernetes Manifests') {
            steps {
                script {
                    update_k8s_manifests(
                        imageTag:       env.DOCKER_IMAGE_TAG,
                        manifestsPath:  'kubernetes',
                        gitCredentials: 'github-credentials',
                        gitUserName:    'Jenkins CI',
                        gitUserEmail:   'misc.lucky66@gmail.com'
                    )
                }
            }
        }
    }

    post {
        always {
            sh 'docker image prune -f'
        }
        success {
            echo "✅ Build ${env.DOCKER_IMAGE_TAG} pushed successfully."
        }
        failure {
            echo "❌ Pipeline failed. Review stage logs above."
        }
    }
}