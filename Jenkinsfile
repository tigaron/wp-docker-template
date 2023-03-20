pipeline {
  agent any

  parameters {
    string(name: 'ec2_instance_name', defaultValue: 'demo-test', description: 'Name of the EC2 instance')
    string(name: 'ec2_instance_type', defaultValue: 't3.micro', description: 'Type of the EC2 instance')
  }

  stages {
    stage('Source') {
      steps {
        echo '||| checkout source code started'
        checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/tigaron/wp-docker-template']]])
        echo '>>> checkout source code completed'
      }
    }

    stage('Provision') {
      steps {
        script {
          echo '||| checking existing ec2 instance'
          def instance = sh(script: "aws ec2 describe-instances --filters \"Name=tag:Name,Values=${params.ec2_instance_name}\" \"Name=instance-state-name,Values=running\" --query \"Reservations[*].Instances[*].[InstanceId]\" --output=text --region=ap-southeast-3", returnStdout: true).trim()

          if (!instance) {
            echo '||| no existing ec2 instance found, creating new instance'
            def newInstance = sh(script: "aws ec2 run-instances --image-id ami-0d2da56e47a445b08 --count 1 --instance-type ${params.ec2_instance_type} --security-group-ids sg-036bf561ef591b061 --subnet-id subnet-0f0f742503601c2cf --iam-instance-profile Name=CloudWatchAgentServerRole --associate-public-ip-address --tag-specifications \"ResourceType=instance,Tags=[{Key=Name,Value=${params.ec2_instance_name}}]\" --region=ap-southeast-3 --query \"Instances[*].InstanceId\" --output=text", returnStdout: true).trim()

            sh "aws ec2 wait instance-status-ok --instance-ids ${newInstance} --region=ap-southeast-3"
            echo '>>> new ec2 instance created'
          }

          echo '>>> provisioning completed'
        }
      }
    }

    stage('Deploy') {
      steps {
        script {
          echo '||| application deployment started'
          def instance = sh(script: "aws ec2 describe-instances --filters \"Name=tag:Name,Values=${params.ec2_instance_name}\" --query \"Reservations[*].Instances[*].[InstanceId]\" --output=text --region=ap-southeast-3", returnStdout: true).trim()
          def command = "cd /home/ssm-user && rm -rf wp-docker-template && git clone https://github.com/tigaron/wp-docker-template && cd wp-docker-template && ./start.sh"

          sh "unbuffer aws ssm start-session --target ${instance} --document-name AWS-StartInteractiveCommand --parameters command=\"${command}\" --region=ap-southeast-3"
          echo '>>> application deployment completed'
        }
      }
    }
  }
}