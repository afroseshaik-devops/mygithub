pipeline {
    agent any

    tools {
        maven 'MAVEN3'
        jdk 'JAVA17'
    }

    environment {
        AWS_REGION = 'ap-south-1'
        ECR_REPO = '339713053602.dkr.ecr.ap-south-1.amazonaws.com/my-spring-app'
        IMAGE_TAG = "latest"
        DEPLOY_SERVER = "ec2-user@3.110.207.37"
        KEY_PATH = "/var/lib/jenkins/.ssh/jenkins-key.pem"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/afroseshaik-devops/mygithub.git'
            }
        }

        stage('Build JAR') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t my-spring-app .
                """
            }
        }

        stage('Login to ECR') {
            steps {
                sh """
                    aws ecr get-login-password --region $AWS_REGION \
                    | docker login --username AWS --password-stdin $ECR_REPO
                """
            }
        }

        stage('Push to ECR') {
            steps {
                sh """
                    docker tag my-spring-app:latest $ECR_REPO:$IMAGE_TAG
                    docker push $ECR_REPO:$IMAGE_TAG
                """
            }
        }

        stage('Deploy to EC2') {
            steps {
                sh """
                    ssh -o StrictHostKeyChecking=no -i $KEY_PATH $DEPLOY_SERVER '
                        docker pull $ECR_REPO:$IMAGE_TAG &&
                        docker stop app || true &&
                        docker rm app || true &&
                        docker run -d --name app -p 8080:8080 $ECR_REPO:$IMAGE_TAG
                    '
                """
            }
        }
    }

    post {
        success { echo "Deployment Successful!" }
        failure { echo "Deployment Failed." }
    }
}
