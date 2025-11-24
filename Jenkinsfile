pipeline {
    agent any

    tools {
        maven 'MAVEN3'      // Name from Jenkins Global Tool Configuration
        jdk 'JAVA17'        // Name from Jenkins Global Tool Configuration
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/afroseshaik-devops/mygithub.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }
     }

    post {
        success {
            echo "Build completed successfully!"
        }
        failure {
            echo "Build failed."
        }
    }
}
