pipeline {
    agent any

    tools {
        maven 'MAVEN3'
        jdk 'JAVA17'
    }

    environment {
        AWS_REGION = 'ap-south-1'
        ECR_REPO = '339713053602.dkr.ecr.ap-south-1.amazonaws.com/my-spring-app'
        IMAGE_TAG = "${BUILD_NUMBER}"
        KUBECONFIG = "/var/lib/jenkins/.kube/config"
        HELM_RELEASE_NAME = "my-spring-app"
        HELM_NAMESPACE = "default"
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

        stage('Deploy to Kubernetes with Helm') {
            steps {
                script {
                    sh """
                        # Ensure Helm is installed
                        helm version
                        
                        # Deploy or upgrade the application using Helm
                        helm upgrade --install ${HELM_RELEASE_NAME} ./helm/demo \
                            --namespace ${HELM_NAMESPACE} \
                            --create-namespace \
                            --set image.repository=${ECR_REPO} \
                            --set image.tag=${IMAGE_TAG} \
                            --set image.pullPolicy=Always \
                            --wait \
                            --timeout 5m
                        
                        # Display deployment status
                        kubectl get pods -n ${HELM_NAMESPACE} -l app.kubernetes.io/name=demo
                        kubectl get svc -n ${HELM_NAMESPACE} -l app.kubernetes.io/name=demo
                    """
                }
            }
        }

    }

    post {
        success { echo "Deployment Successful!" }
        failure { echo "Deployment Failed." }
    }
}
