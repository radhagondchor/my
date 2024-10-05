pipeline {
    agent any

    stages {
        stage('code check') {
            steps {
                git branch: 'master', url: 'https://github.com/radhagondchor/my_tool_es.git'
            }
        }
        stage('ES') {
            steps {
                sh 'ansible-playbook -i aws_ec2.yaml install.yml'  // Correct inventory and playbook
            }
        }
        stage('Kibana') {
            steps {
                sh 'ansible-playbook -i aws_ec2.yaml kibana.yml'  // Correct inventory and playbook
            }
        }
    }
}
