pipeline {
  agent any

  parameters {
    string(name: 'ec2_instance_name', defaultValue: '', description: 'Name of the EC2 instance')
    string(name: 'ec2_instance_type', defaultValue: '', description: 'Type of the EC2 instance')
  }

  stages {
    stage('Source') {
      steps {
        checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/tigaron/wp-docker-template']]])
      }
    }

    stage('Provision') {
      steps {
        script {
          def instance = sh(script: "aws ec2 describe-instances --filters \"Name=tag:Name,Values=${params.ec2_instance_name}\" --query \"Reservations[*].Instances[*].[InstanceId]\" --output=text --region=ap-southeast-3", returnStdout: true).trim()

          if (!instance) {
            sh "ansible-playbook create-ec2.yml -e \"instance_name=${params.ec2_instance_name} instance_type=${params.ec2_instance_type}\""
          }

          sh "echo Instance ID: ${instance}"
        }
      }
    }

    stage('Deploy') {
      steps {
        script {
          def instance = sh(script: "aws ec2 describe-instances --filters \"Name=tag:Name,Values=${params.ec2_instance_name}\" --query \"Reservations[*].Instances[*].[InstanceId]\" --output=text --region=ap-southeast-3", returnStdout: true).trim()
          def command = "aws ssm start-session --target ${instance} --region=ap-southeast-3 --document-name AWS-StartInteractiveCommand --parameters command=\"cd /home/ssm-user && rm -rf wp-docker-template && git clone https://github.com/tigaron/wp-docker-template && cd wp-docker-template && docker-compose up -d\""

          sh command
        }
      }
    }
  }
}