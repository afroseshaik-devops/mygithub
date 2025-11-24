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
                    url: 'https://github.com/<your-username>/<your-repo>.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Run JAR') {
            steps {
                // Stop previous running app (optional)
                sh 'pkill -f "*.jar" || true'

                sh 'nohup java -jar target/*.jar > app.log 2>&1 &'
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
