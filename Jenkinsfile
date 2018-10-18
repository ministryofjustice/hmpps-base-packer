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
        bash -c 'ansible-galaxy install -r ansible/requirements.yml; USER=`whoami` packer validate ''' + filename + "'"
    }
}

def verify_win_image(filename) {
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
        bash -c 'USER=`whoami` packer validate """ + filename + "'"
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

def build_win_image(filename) {
    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
        sh """
        #!/usr/env/bin bash
        set +x
        docker run --rm \
        -e BRANCH_NAME \
        -e TARGET_ENV \
        -e ARTIFACT_BUCKET \
        -e ZAIZI_BUCKET \
        -e WIN_ADMIN_PASS="${env.WIN_ADMIN_PASS}" \
        -e WIN_ADMIN_USER="${env.WIN_ADMIN_USER}" \
        -e WIN_JENKINS_PASS="${env.WIN_JENKINS_PASS}" \
        -e WIN_JENKINS_USER="${env.WIN_JENKINS_USER}" \
        -v `pwd`:/home/tools/data \
        mojdigitalstudio/hmpps-packer-builder \
        bash -c 'USER=`whoami` packer build """ + filename + "'"
    }
}

pipeline {
    agent { label "!master"}

    environment {
        WIN_ADMIN_PASS   = '$(aws ssm get-parameters --names /dev/jenkins/windows/slave/admin/password --region eu-west-2 --with-decrypt --query Parameters[0].Value | sed \'s/"//g\')'
        WIN_ADMIN_USER   = '$(aws ssm get-parameters --names /dev/jenkins/windows/slave/admin/user --region eu-west-2 --query Parameters[0].Value | sed \'s/"//g\')'
        WIN_JENKINS_PASS = '$(aws ssm get-parameters --names /dev/jenkins/windows/slave/jenkins/password --region eu-west-2 --with-decrypt --query Parameters[0].Value | sed \'s/"//g\')'
        WIN_JENKINS_USER = '$(aws ssm get-parameters --names /dev/jenkins/windows/slave/jenkins/user --region eu-west-2 --query Parameters[0].Value | sed \'s/"//g\')'
    }

    stages {
        stage ('Notify build started') {
            steps {
                slackSend(message: "Build Started - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL.replace(':8080','')}|Open>)")
            }
        }

        stage('Verify Packer Linux AMIS') {
            parallel {
                stage('Verify Amazon Linux') { steps { script {verify_image('amazonlinux.json')}}}
                stage('Verify Amazon Linux 2') { steps { script {verify_image('amazonlinux2.json')}}}
                stage('Verify Amazon Linux 2 Jenkins Slave') { steps { script {verify_image('jenkins_slave.json')}}}
                stage('Verify Centos 7') { steps { script {verify_image('centos7.json')}}}
            }
        }

        stage('Verify Packer Windows AMIS') {
            parallel {
                stage('Verify Windows Server Base') { steps { script {verify_win_image('windows_base.json')}}}
            }
        }

        //stage('Build Packer Linux AMIS') {
        //    parallel {
        //        stage('Build Amazon Linux') { steps { script {build_image('amazonlinux.json')}}}
        //        stage('Build Amazon Linux 2') { steps { script {build_image('amazonlinux2.json')}}}
        //        stage('Build Amazon Linux 2 Jenkins Slave') { steps { script {build_image('jenkins_slave.json')}}}
        //        stage('Build Centos 7') { steps { script {build_image('centos7.json')}}}
        //    }
        //}

        stage('Build Packer Windows Base AMIS') {
            parallel {
                stage('Build Windows Server Base') { steps { script {build_win_image('windows_base.json')}}}
            }
        }

        stage('Build Packer Windows AMIS') {
            parallel {
                stage('Build Windows Server Jenkins Slave') { steps { script {build_win_image('windows_slave.json')}}}
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
