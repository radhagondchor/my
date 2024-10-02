pipeline {
    agent any
    
    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
    }
    
    stages {
        stage('Installing kibana') {
            steps {
                script {
                    ansiblePlaybook(
                        playbook: 'install.yaml',
                        inventory: 'aws_ec2.yaml',
                        credentialsId: 'tool.pem'
                    )
                }
            }
        }
    }
}
