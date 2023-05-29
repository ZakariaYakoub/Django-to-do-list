pipeline {

    agent any
    stages {

        stage('provision ec2 instance') {
            environment {
                AWS_ACCESS_KEY_ID = credentials("jenkins_aws_access_key_id")
                AWS_SECRET_ACCESS_KEY = credentials("jenkins_aws_secret_access_key")
            }
            steps {
                script {
                    dir('terraform') {
                        sh "terraform init"
                        sh "terraform apply --auto-approve"
                        MY_IP = sh(script: "terraform output instance_ip",returnStdout: true).trim()
                    }
                }
            }
        }

        stage('Build docker image') {
            steps {
                script {
                    echo "setting the ip address in allowed_host in setting.py"
                    dir("src/project/project"){
                        sh "MY_IP=${MY_IP} envsubst  < settings.py > settings_temp.py && mv settings_temp.py settings.py"
                    }
                    sh "docker build -t django-app:${BUILD_NUMBER} ."
                }
            }
        }

        stage("Push Image to ECR") {
            environment {
                    AWS_ACCESS_KEY_ID = credentials("jenkins_aws_access_key_id")
                    AWS_SECRET_ACCESS_KEY = credentials("jenkins_aws_secret_access_key")
                }
            steps {
                script {
                    sh "aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 474871713933.dkr.ecr.eu-central-1.amazonaws.com"
                    sh "docker tag django-app:${BUILD_NUMBER} 474871713933.dkr.ecr.eu-central-1.amazonaws.com/django-app:${BUILD_NUMBER}"
                    sh "docker push 474871713933.dkr.ecr.eu-central-1.amazonaws.com/django-app:${BUILD_NUMBER}"
                }
            }
        }



        stage("Deploy app to provisionned server"){
            steps {
                script {
                    echo "calling ansible playbook to configure ec2 instance server"
                    def remote= [:]
                    remote.name = "ansible-server"
                    remote.host = "20.111.8.195"
                    remote.allowAnyHosts = true
                    withCredentials([sshUserPrivateKey(credentialsId:'ansible-server-key',keyFileVariable: 'keyfile',usernameVariable:'user')]){
                        remote.user = user
                        remote.identityFile = keyfile
                        sshCommand remote: remote, command: "cd ansible-django && sudo ansible-playbook deploy-app.yaml --extra-vars 'build_number=${BUILD_NUMBER}' --vault-password-file=vault-password"
                    }
                }
            }
        }

    }
}