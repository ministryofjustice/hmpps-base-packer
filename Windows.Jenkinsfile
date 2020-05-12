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
        -e WIN_MIS_USER="${env.WIN_MIS_USER}" \
        -e WIN_MIS_PASS="${env.WIN_MIS_PASS}" \
        -e WIN_JENKINS_PASS="${env.WIN_JENKINS_PASS}" \
        -e WIN_BOBJ_USER="${env.WIN_BOBJ_USER}" \
        -e WIN_BOBJ_PASS="${env.WIN_BOBJ_PASS}" \
        -v `pwd`:/home/tools/data \
        mojdigitalstudio/hmpps-packer-builder \
        bash -c 'USER=`whoami` packer build -debug """ + filename + "'"
    }
}

pipeline {
    agent { label "jenkins_slave"}

    options {
        ansiColor('xterm')
    }

    triggers {
        cron(env.BRANCH_NAME=='master'? 'H 2 * * 6': '')
    }

    environment {
        WIN_ADMIN_PASS   = '$(aws ssm get-parameters --names /${TARGET_ENV}/jenkins/windows/slave/admin/password --region eu-west-2 --with-decrypt --query Parameters[0].Value | sed \'s/"//g\')'
        WIN_JENKINS_PASS = '$(aws ssm get-parameters --names /${TARGET_ENV}/jenkins/windows/slave/jenkins/password --region eu-west-2 --with-decrypt --query Parameters[0].Value | sed \'s/"//g\')'
        WIN_MIS_USER     = '$(aws ssm get-parameters --names /${TARGET_ENV}/jenkins/windows/mis/user --region eu-west-2 --query Parameters[0].Value | sed \'s/"//g\')'
        WIN_MIS_PASS     = '$(aws ssm get-parameters --names /${TARGET_ENV}/jenkins/windows/mis/password --region eu-west-2 --with-decrypt --query Parameters[0].Value | sed \'s/"//g\')'
        WIN_BOBJ_USER    = '$(aws ssm get-parameters --names /${TARGET_ENV}/jenkins/windows/busobj/user --region eu-west-2 --query Parameters[0].Value | sed \'s/"//g\')'
        WIN_BOBJ_PASS    = '$(aws ssm get-parameters --names /${TARGET_ENV}/jenkins/windows/busobj/password --region eu-west-2 --with-decrypt --query Parameters[0].Value | sed \'s/"//g\')'

    }

    stages {
        stage ('Notify build started') {
            steps {
                slackSend(message: "Build Started - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL.replace(':8080','')}|Open>)")
            }
        }

        stage('Verify Packer AMIS') {
            parallel {
                stage('Verify Windows Server Base') { steps { script {verify_win_image('windows_base.json')}}}
                stage('Verify Windows Server Jenkins Slave') { steps { script {verify_win_image('windows_slave.json')}}}
                stage('Verify Windows Server MIS Nart') { steps { script {verify_win_image('windows_misnart.json')}}}
                stage('Verify Windows Server MIS Nart BCS') { steps { script {verify_win_image('windows_misnart_bcs.json')}}}
                stage('Verify Windows Server MIS Nart BFS') { steps { script {verify_win_image('windows_misnart_bfs.json')}}}
            }
        }

        stage('Build Packer Base AMIS') {
            parallel {
                stage('Build Windows Server Base') { steps { script {build_win_image('windows_base.json')}}}
            }
        }

        stage('Build Packer Dependant AMIS') {
            parallel {
                stage('Build Windows Server Jenkins Slave') { steps { script {build_win_image('windows_slave.json')}}}
                stage('Build Windows Server MIS Nart') { steps { script {build_win_image('windows_misnart.json')}}}
            }
        }

        stage('Build Packer MIS Dependant AMIS') {
            parallel {
                stage('Build Windows Server MIS Nart BCS') { steps { script {build_win_image('windows_misnart_bcs.json')}}}
                stage('Build Windows Server MIS Nart BFS') { steps { script {build_win_image('windows_misnart_bfs.json')}}}
            }
        }
    }

    post {
        always {
            deleteDir()
        }
        success {
            slackSend(message: "Build completed - ${env.JOB_NAME} ${env.BUILD_NUMBER}", color: 'good')
        }
        failure {
            slackSend(message: "Build failed - ${env.JOB_NAME} ${env.BUILD_NUMBER}", color: 'danger')
        }
    }
}