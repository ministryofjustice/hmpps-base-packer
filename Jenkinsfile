def verify_image(filename) {
    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
        sh '''
        #!/usr/env/bin bash
        set +x
        docker run --rm \
        -e BRANCH_NAME \
        -e TARGET_ENV \
        -e ARTIFACT_BUCKET \
        -e ZAIZI_BUCKET \
        -v `pwd`:/home/tools/data \
        mojdigitalstudio/hmpps-packer-builder \
        bash -c 'USER=`whoami` packer validate ''' + filename + "'"
    }
}

def build_image(filename) {
    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
        sh """
        #!/usr/env/bin bash
        set +x
        docker run --rm \
        -e BRANCH_NAME \
        -e TARGET_ENV \
        -e ARTIFACT_BUCKET \
        -e ZAIZI_BUCKET \
        -v `pwd`:/home/tools/data \
        mojdigitalstudio/hmpps-packer-builder \
        bash -c 'ansible-galaxy install -r ansible/requirements.yml; USER=`whoami` packer build """ + filename + "'"
    }
}

pipeline {
    agent { label "jenkins_slave"}

    stages {
        stage ('Notify build started') {
            steps {
                slackSend(message: "Build Started - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL.replace(':8080','')}|Open>)")
            }
        }

        stage('Verify Packer AMIS') {
            parallel {
                stage('Verify Amazon Linux') { steps { script {verify_image('amazonlinux.json')}}}
                stage('Verify Centos 7') { steps { script {verify_image('centos7.json')}}}
                stage('Verify Centos 7 Jenkins Slave') { steps { script {verify_image('jenkins_slave_centos.json')}}}
                stage('Verify Centos 7 ECS-Ready') { steps { script {verify_image('centos_ecs.json')}}}
                stage('Verify Amazon Linux 2 Jenkins Slave') { steps { script {verify_image('jenkins_slave.json')}}}
            }
        }

        stage('Build Packer Base AMIS') {
            parallel {
                stage('Build Amazon Linux') { steps { script {build_image('amazonlinux.json')}}}
                stage('Build Centos 7') { steps { script {build_image('centos7.json')}}}
                stage('Build Amazon Linux 2 Jenkins Slave') { steps { script {build_image('jenkins_slave.json')}}}
            }
        }

        stage('Build Packer Dependanty AMIS') {
            parallel {
                stage('Build Centos Jenkins Slave') { steps { script {build_image('jenkins_slave_centos.json')}}}
                stage('Build Centos 7 ECS-Ready') { steps { script {build_image('centos_ecs.json')}}}
            }
        }
    }

    post {
        success {
            slackSend(message: "Build completed - ${env.JOB_NAME} ${env.BUILD_NUMBER}", color: 'good')
        }
        failure {
            slackSend(message: "Build failed - ${env.JOB_NAME} ${env.BUILD_NUMBER}", color: 'danger')
        }
    }
}
