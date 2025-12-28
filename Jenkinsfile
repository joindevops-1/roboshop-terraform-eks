pipeline {
    // These are pre-build sections
    agent {
        node {
            label 'AGENT-1'
        }
    }
    environment {
        COURSE = "Jenkins"
    }
    options {
        timeout(time: 10, unit: 'MINUTES') 
        disableConcurrentBuilds()
        ansiColor('xterm')
    }
    
    parameters {
        
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Pick something')
    }
    // This is build section
    stages {
        
        stage('VPC apply'){
            when { expression { params.ACTION == 'apply' } }
            steps { 
                terraformRun('00-vpc') 
            }
        }
        stage('SG apply'){
            when { expression { params.ACTION == 'apply' } }
            steps { 
                terraformRun('10-sg') 
            }
        }
        stage('Parellel apply'){
            when { expression { params.ACTION == 'apply' } }
            parallel {
                stage('Bastion')   {
                    steps {
                         terraformRun('20-bastion') 
                    }
                }
                stage('SG Rules')   {
                    steps {
                         terraformRun('30-sg-rules') 
                    }
                }
                stage('ECR')   {
                    steps {
                         terraformRun('40-ecr') 
                    }
                }
                stage('ACM')   {
                    steps {
                         terraformRun('70-acm') 
                    }
                }
                stage('EKS')   {
                    steps {
                         terraformRun('90-eks') 
                    }
                }
            }
        }
        stage('Frontend ALB apply'){
            when { expression { params.ACTION == 'apply' } }
            steps { 
                terraformRun('80-frontend-alb') 
            }
        }
// Destroy Flow //
        stage('Parellel Destroy'){
            when { expression { params.ACTION == 'destroy' } }
            parallel {
                stage('Bastion')   {
                    steps {
                         terraformRun('20-bastion') 
                    }
                }
                stage('SG Rules')   {
                    steps {
                         terraformRun('30-sg-rules') 
                    }
                }
                stage('ECR')   {
                    steps {
                         terraformRun('40-ecr') 
                    }
                }
                stage('Frontend ALB'){
                    steps { 
                        terraformRun('80-frontend-alb') 
                    }
                }
                
                stage('EKS')   {
                    steps {
                         terraformRun('90-eks') 
                    }
                }
                
            }
        }
        stage('ACM Destory'){
            when { expression { params.ACTION == 'destroy' } }
            steps {
                    terraformRun('70-acm') 
            }
        }
        stage('SG Destory'){
            when { expression { params.ACTION == 'destroy' } }
            steps { 
                terraformRun('10-sg') 
            }
        }
        stage('VPC Destory'){
            when { expression { params.ACTION == 'destroy' } }
            steps { 
                terraformRun('00-vpc') 
            }
        }
        
    }
    post{
        always{
            echo 'I will always say Hello again!'
            cleanWs()
        }
        success {
            echo 'I will run if success'
        }
        failure {
            echo 'I will run if failure'
        }
        aborted {
            echo 'pipeline is aborted'
        }
    }
}

def terraformRun(String dirName) {
  dir(dirName) {
    withAWS(credentials: 'aws-creds', region: 'us-east-1') {
        sh """
        set -euo pipefail
        echo "=== Terraform ${params.ACTION.toUpperCase()} @ ${dirName} ==="

        terraform --version
        terraform init

        if [ "${params.ACTION}" = "apply" ]; then
            terraform plan -out=tfplan -input=false
            terraform apply -input=false -auto-approve tfplan
        else
            terraform destroy -auto-approve
        fi
        """
    }
  }
}