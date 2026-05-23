@Library('Shared') _

pipeline {
    agent any
    
    options {
        parallelsAlwaysFailFast()  // Global failFast for ALL parallel stages for aws resources cost optimization
        timeout(time: 1, unit: 'HOURS')  // Additional safety - max pipeline runtime
        buildDiscarder(logRotator(numToKeepStr: '10'))  // Keep last 10 builds only
    }
    
    environment {
        // Your Docker Hub username
        DOCKER_IMAGE_NAME = 'alimafunzo/easyshop-app'
        DOCKER_MIGRATION_IMAGE_NAME = 'alimafunzo/easyshop-migration'
        DOCKER_IMAGE_TAG = "${BUILD_NUMBER}"
        GITHUB_CREDENTIALS = credentials('github-credentials')
        GIT_BRANCH = "main"
        REPO_URL = "https://github.com/abdoulKARENZO-max/3-tier-app-cloud-devops-e-commmerce-proj.git"
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
                    clone(env.REPO_URL, env.GIT_BRANCH)
                }
            }
        }
        
        stage('Build Docker Images') {
            parallel {
                stage('Build Main App Image') {
                    steps {
                        script {
                            docker_build(
                                imageName: env.DOCKER_IMAGE_NAME,
                                imageTag: env.DOCKER_IMAGE_TAG,
                                dockerfile: 'Dockerfile',
                                context: '.'
                            )
                        }
                    }
                }
                
                stage('Build Migration Image') {
                    steps {
                        script {
                            docker_build(
                                imageName: env.DOCKER_MIGRATION_IMAGE_NAME,
                                imageTag: env.DOCKER_IMAGE_TAG,
                                dockerfile: 'scripts/Dockerfile.migration',
                                context: '.'
                            )
                        }
                    }
                }
            }
            // No need for individual failFast - handled globally
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
                stage('Push Main App Image') {
                    steps {
                        script {
                            docker_push(
                                imageName: env.DOCKER_IMAGE_NAME,
                                imageTag: env.DOCKER_IMAGE_TAG,
                                credentialsId: 'docker-hub-credentials'
                            )
                        }
                    }
                }
                
                stage('Push Migration Image') {
                    steps {
                        script {
                            docker_push(
                                imageName: env.DOCKER_MIGRATION_IMAGE_NAME,
                                imageTag: env.DOCKER_IMAGE_TAG,
                                credentialsId: 'docker-hub-credentials'
                            )
                        }
                    }
                }
            }
            // No need for individual failFast - handled globally
        }
        
        stage('Update Kubernetes Manifests') {
            steps {
                script {
                    update_k8s_manifests(
                        imageTag: env.DOCKER_IMAGE_TAG,
                        manifestsPath: 'kubernetes',
                        gitCredentials: 'github-credentials',
                        gitUserName: 'Abdoul KARENZO',
                        gitUserEmail: 'abdoulkarenzo-max@users.noreply.github.com',
                        gitBranch: env.GIT_BRANCH,
                        repoUrl: env.REPO_URL
                    )
                }
            }
        }
    }
    
    post {
        always {
            script {
                clean_ws()
                echo "Pipeline completed at: ${new Date()}"
            }
        }
        success {
            echo "✅ Pipeline SUCCESSFUL!"
            echo "📦 Images pushed:"
            echo "   - ${env.DOCKER_IMAGE_NAME}:${env.DOCKER_IMAGE_TAG}"
            echo "   - ${env.DOCKER_MIGRATION_IMAGE_NAME}:${env.DOCKER_IMAGE_TAG}"
            echo "🔧 Kubernetes manifests updated with new image tags"
        }
        failure {
            echo "❌ Pipeline FAILED at stage: ${env.STAGE_NAME}"
            echo "Check build logs for details: ${env.BUILD_URL}"
        }
        aborted {
            echo "⚠️ Pipeline was aborted"
        }
    }
}