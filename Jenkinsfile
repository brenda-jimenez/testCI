pipeline {
    agent {
        label 'lineage-build-box'
    }
    tools {
        nodejs "node"
    }
    options { buildDiscarder(logRotator(numToKeepStr: '3')) }
    stages {
        stage('Build PR') {
            when { changeRequest() }
            steps {
                script {
                    echo("PR: building and running tests")

                    sh 'yarn'
                    sh 'yarn run init'
                    sh 'yarn codegen'
                    sh 'yarn build'
                    sh 'yarn test:unit'
                    sh 'yarn test -- --scope=@lineage/ufo-e2e'
                    sh 'yarn test -- --scope=@lineage/dock-e2e'
                }
            }
        }
        stage('Build-Docker-Dock') {
            when { tag '@lineage/dock@*' }
            steps {
                echo("Release-Dock: Building image and pushing to QA registry.")
                script {
                    docker.withRegistry('https://160965362920.dkr.ecr.us-east-1.amazonaws.com/lineage', 'ecr:us-east-1:Lineage Service Account') {
                        def customImage = docker.build("lineage:dock", "-f ./docker/dock-dev.Dockerfile .")

                        customImage.push()
                    }
                }
                echo("Release-Dock: Building image and pushing to staging (Quay) registry.")
                script {
                    docker.withRegistry('https://quay.io', 'Keith_Quay') {
                        def version = env.BRANCH_NAME.split("@")[2]
                        def customImage = docker.build("quay.io/lineage/dock-app:${version}", "-f ./docker/dock.Dockerfile .")

                        customImage.push()
                    }
                }
            }
        }
        stage('Build-QA-AWS-UFO') {
            when {  
                    branch 'qa' 
                    tag '@lineage/ufo@*'
                 }
            steps {
                echo("Release-UFO: Building image and pushing to QA registry.")
                script {
                    docker.withRegistry('https://160965362920.dkr.ecr.us-east-1.amazonaws.com/lineage', 'ecr:us-east-1:Lineage Service Account') {
                        def customImage = docker.build("lineage:ufo", "-f ./docker/ufo-dev.Dockerfile .")

                        customImage.push()
                    }
                }
            }
        }
        stage('Build-Staging-UFO') {
            when {  
                    branch 'staging' 
                    tag '@lineage/ufo@*'
                 }
            steps {
                echo("Release-UFO: Building image and pushing to staging (Quay) registry.")
                script {
                    docker.withRegistry('https://quay.io', 'Keith_Quay') {
                        def version = env.BRANCH_NAME.split("@")[2]
                        def customImage = docker.build("quay.io/lineage/ufo-app:${version}", "-f ./docker/ufo.Dockerfile .")

                        customImage.push()
                    }
                }
            }
        }
        stage('Build-Docker-HTTP-Logger') {
          when { tag '@lineage/http-logger@*' }
          steps {
            echo("Release-HTTP-Logger: Build http-logger image and pushing to staging (Quay) registry.")
                script {
                    docker.withRegistry('https://quay.io', 'Keith_Quay') {
                        def version = env.BRANCH_NAME.split("@")[2]
                        def customImage = docker.build("quay.io/lineage/http-logger:${version}", "-f ./docker/http-logger.Dockerfile .")

                        customImage.push()
                    }
                }
          }
        }
        stage('Deploy-Dock') {
            when { tag '@lineage/dock@*' }
            steps {
                echo("Deploy-Dock: Executing deploy script in QA environment.");
                sshagent (credentials: ['303a297d-033d-42b8-9d3d-4598e0730320']) {
                    sh 'ssh -o StrictHostKeyChecking=no -l ec2-user ec2-52-7-214-26.compute-1.amazonaws.com "sh run-deploy.sh"'
                }
            }
        }
        stage('Deploy-UFO') {
            when { tag '@lineage/ufo@*' }
            steps {
                echo("Deploy-UFO: Executing deploy script in QA environment.");
                sshagent (credentials: ['303a297d-033d-42b8-9d3d-4598e0730320']) {
                    sh 'ssh -o StrictHostKeyChecking=no -l ec2-user ec2-52-7-214-26.compute-1.amazonaws.com "sh ufo-run-deploy.sh"'
                }
            }
        }
        stage('Clean-Up') {
            when { branch 'master' }
            steps {
              echo("Clean-Up: Removing stopped containers/unused images.");

              sh 'docker system prune -f'

              sshagent (credentials: ['303a297d-033d-42b8-9d3d-4598e0730320']) {
                sh 'ssh -o StrictHostKeyChecking=no -l ec2-user ec2-52-7-214-26.compute-1.amazonaws.com "docker system prune -f"'
              }
            }
        }
    }
}
