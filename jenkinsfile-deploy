pipeline {
    agent any
    
    stages {
        stage('Terraform Apply') {
            steps {
                sh 'terraform init'
                sh 'terraform plan'
                sh 'terraform validate'
                sh 'terraform apply -auto-approve'
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}