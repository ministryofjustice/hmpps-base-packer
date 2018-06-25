def verify_image(filename) {
    sh '''
    #!/usr/env/bin bash
    docker run --rm -v `pwd`:/home/tools/data mojdigitalstudio/hmpps-packer-builder bash -c 'packer inspect ''' + filename + "'"
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
            }
        }
    }
}