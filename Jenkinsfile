pipeline {
    agent any
    tools {
        jdk 'jdk17'
        maven 'Default Maven'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        registry = 'greyabiwon/addressbook'
        registryCredential = 'docker-login'
        slack = 'slack'
    }
    stages {
        stage('Clean workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout from Git') {
            steps {
                git branch: 'main', url: 'https://github.com/grey1001/EdurekaDevOpsClassCodes.git'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                script {
                    def mvn = tool 'Default Maven'
                    withSonarQubeEnv() {
                        sh "${mvn}/bin/mvn clean verify sonar:sonar -Dsonar.projectKey=addressbook -Dsonar.projectName='addressbook'"
                    }
                }
            }
        }
        stage("Quality Gate") {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
                }
            }
        }
        stage('Compile') {
            steps {
                script {
                    sh 'mvn compile'
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    sh 'mvn test'
                }
            }
        }
        stage('Package') {
            steps {
                script {
                    sh 'mvn package'
                }
            }
        }
        stage('Building image') {
            steps {
                script {
                    dockerImage = docker.build("${registry}:v${BUILD_NUMBER}")
                }
            }
        }
        stage('Trivy Scan') {
            steps {
                script {
                    // Define the Docker image name and tag (replace with your actual image name and tag)
                    def dockerImageName = "${registry}:${BUILD_NUMBER}"

                    // Run Trivy scan on your Docker image
                    def trivyScanResult = sh(script: "trivy image ${dockerImageName}", returnStatus: true)

                    if (trivyScanResult == 0) {
                        echo 'Trivy scan passed. No vulnerabilities found.'
                    } else {
                        error 'Trivy scan failed. Vulnerabilities detected.'
                    }
                }
            }
        }
        stage('Deploy Image') {
            steps {
                script {
                    docker.withRegistry('', registryCredential) {
                        dockerImage.push("v${BUILD_NUMBER}")
                    }
                }
            }
        }
    }

    post {
        failure {
            slackSend(
                color: '#FF0000',
                message: "Pipeline failed: ${currentBuild.fullDisplayName}",
                tokenCredentialId: 'slack',
                channel: '#devops-cicd'
            )
        }
        success {
            slackSend(
                color: 'good',
                message: "Pipeline succeeded: ${currentBuild.fullDisplayName}",
                tokenCredentialId: 'slack',
                channel: '#devops-cicd'
            )
        }
    }
}
