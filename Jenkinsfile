pipeline {
    agent any

    tools {
        maven 'maven3'
        jdk 'java11'
    }

    environment {
        TOMCAT_USER = 'ec2-user'
        TOMCAT_HOST = "${env.TOMCAT_PRIVATE_IP}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Package WAR') {
            steps {
                sh 'mvn package -DskipTests'
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                sshagent(credentials: ['tomcat-ssh']) {
                    sh """
                    scp target/java-auto-app.war ${TOMCAT_USER}@${TOMCAT_HOST}:/opt/tomcat/webapps/
                    ssh ${TOMCAT_USER}@${TOMCAT_HOST} 'sudo systemctl restart tomcat'
                    """
                }
            }
        }
    }

    post {
        success {
            sh '''
            curl -X POST -H "Content-type: application/json" \
            --data '{"text":"✅ Deployment successful: WAR deployed to Tomcat"}' \
            $SLACK_WEBHOOK
            '''
        }

        failure {
            sh '''
            curl -X POST -H "Content-type: application/json" \
            --data '{"text":"❌ Deployment failed. Check Jenkins logs"}' \
            $SLACK_WEBHOOK
            '''
        }
    }
}
