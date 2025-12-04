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
        DEPLOY_SERVER = "ec2-user@3.109.210.15"
        KEY_PATH = "/var/lib/jenkins/.ssh/jenkins-key.pem"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                echo "Building branch: ${env.GIT_BRANCH}"
            }
        }

        stage('Build WAR') {
            steps {
                sh 'mvn clean package -DskipTests'
                sh 'mv target/*.war target/demo.war'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t my-wildfly-app .'
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
                    docker tag my-wildfly-app:latest $ECR_REPO:$IMAGE_TAG
                    docker push $ECR_REPO:$IMAGE_TAG
                """
            }
        }

        /* FIXED APPROVAL STAGE */
        stage('Approve Deploy') {
            agent none
            steps {
                script {
                    timeout(time: 15, unit: 'MINUTES') {
                        input message: "Deploy to EC2?"
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sh """
ssh -o StrictHostKeyChecking=no -i $KEY_PATH $DEPLOY_SERVER << 'EOF'
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin $ECR_REPO

docker pull $ECR_REPO:$IMAGE_TAG

docker stop app || true
docker rm app || true

docker run -d --name app -p 8080:8080 $ECR_REPO:$IMAGE_TAG
EOF
"""
            }
        }
    }

    post {
        success { echo "Deployment Successful!" }
        failure { echo "Deployment Failed." }
    }
}
