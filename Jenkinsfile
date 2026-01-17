pipeline {
  agent any

  tools {
    maven 'maven3'
  }

  environment {
    TOMCAT_HOST = "<TOMCAT_PRIVATE_IP>"
    TOMCAT_PATH = "/opt/tomcat/webapps"
    SLACK_WEBHOOK = credentials('slack-webhook')
  }

  stages {

    stage('Checkout') {
      steps {
        git branch: 'main',
            url: 'https://github.com/sheezylion/java-automated-app.git'
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
            scp target/*.war ec2-user@${TOMCAT_HOST}:${TOMCAT_PATH}/
            ssh ec2-user@${TOMCAT_HOST} 'sudo systemctl restart tomcat'
          """
        }
      }
    }
  }

  post {
    success {
      sh """
        curl -X POST -H 'Content-type: application/json' \
        --data '{"text":"✅ Deployment successful to Tomcat"}' \
        $SLACK_WEBHOOK
      """
    }
    failure {
      sh """
        curl -X POST -H 'Content-type: application/json' \
        --data '{"text":"❌ Deployment failed. Check Jenkins logs"}' \
        $SLACK_WEBHOOK
      """
    }
  }
}
