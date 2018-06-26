def verify_image(filename) {
    sh '''
    #!/usr/env/bin bash
    docker run --rm -v `pwd`:/home/tools/data mojdigitalstudio/hmpps-packer-builder bash -c 'USER=`whoami` packer validate ''' + filename + "'"
}

def build_image(filename) {
    sh '''
    #!/usr/env/bin bash
    docker run --rm -v `pwd`:/home/tools/data mojdigitalstudio/hmpps-packer-builder bash -c 'ansible-galaxy install -r ansible/requirements.yml; USER=`whoami` packer build ''' + filename + "'"
}

pipeline {
    agent { label "!master"}

    stages {
        stage('Verify Packer AMIS') {
            parallel {
                stage('Verify Amazon Linux') { steps { script {verify_image('amazonlinux.json')}}}
                stage('Verify Amazon Linux 2') { steps { script {verify_image('amazonlinux2.json')}}}
                stage('Verify Amazon Linux 2 Jenkins Slave') { steps { script {verify_image('amazonlinux2jenkins_slave.json')}}}
                stage('Verify Centos 7') { steps { script {verify_image('centos7.json')}}}
                stage('Verify Oracle Linux') { steps { script {verify_image('oraclelinux.json')}}}
            }
        }

        stage('Build Packer AMIS') {
            parallel {
                stage('Build Amazon Linux') { steps { script {build_image('amazonlinux.json')}}}
                stage('Build Amazon Linux 2') { steps { script {build_image('amazonlinux2.json')}}}
                stage('Build Amazon Linux 2 Jenkins Slave') { steps { script {build_image('amazonlinux2jenkins_slave.json')}}}
                stage('Build Centos 7') { steps { script {build_image('centos7.json')}}}
                stage('Build Oracle Linux') { steps { script {build_image('oraclelinux.json')}}}
            }
        }
    }
}