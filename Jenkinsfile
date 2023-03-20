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

          def status = sh(script: "aws ec2 describe-instance-status --instance-ids ${instance} --query \"InstanceStatuses[*].InstanceState.Name\" --output=text --region=ap-southeast-3", returnStdout: true).trim()

          if (!instance || status != 'running') {
            def command = "aws ec2 run-instances --image-id ami-0d2da56e47a445b08 --count 1 --instance-type ${params.ec2_instance_type} --security-group-ids sg-036bf561ef591b061 --subnet-id subnet-0f0f742503601c2cf --associate-public-ip-address --tag-specifications \"ResourceType=instance,Tags=[{Key=Name,Value=${params.ec2_instance_name}}]\" --region=ap-southeast-3"

            sh command
          }

          sh "aws ec2 wait instance-status-ok --instance-ids ${instance} --region=ap-southeast-3"
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