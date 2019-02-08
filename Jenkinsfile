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
        # virtualenv venv_${filename} -p python3
        # . venv_${filename}/bin/activate
        # pip install -r requirements.txt
        # python3 generate_metadata.py ${filename}
        # deactivate
        # rm -rf venv_${filename}

        set +x
        docker run --rm \
        -e BRANCH_NAME \
        -e TARGET_ENV \
        -e ARTIFACT_BUCKET \
        -e ZAIZI_BUCKET \
        -v `pwd`:/home/tools/data \
        mojdigitalstudio/hmpps-packer-builder \
        bash -c 'ansible-galaxy install -r ansible/requirements.yml; \
        PACKER_VERSION=`packer --version` USER=`whoami` packer build ${filename}'
        #rm ./meta/${filename}_meta.json
        """
    }
}

pipeline {
    agent { label "python3"}

    options {
        ansiColor('xterm')
    }

    triggers {
        cron(env.BRANCH_NAME=='master'? 'H 2 * * *': '')
    }

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
                stage('Verify Centos 7 Docker Base') { steps { script {verify_image('centos_docker.json')}}}
                stage('Verify Centos 7 Jenkins Slave') { steps { script {verify_image('jenkins_slave_centos.json')}}}
                stage('Verify Centos 7 ECS-Ready') { steps { script {verify_image('centos_ecs.json')}}}
                stage('Verify Amazon Linux 2 Jenkins Slave') { steps { script {verify_image('jenkins_slave.json')}}}
                stage('Verify Kali Linux Jenkins Slave') { steps { script {verify_image('jenkins_slave_kali.json')}}}
            }
        }

        stage('Build Packer Base AMIS') {
            parallel {
                stage('Build Amazon Linux') { steps { script {build_image('amazonlinux.json')}}}
                stage('Build Centos 7') { steps { script {build_image('centos7.json')}}}
                stage('Build Amazon Linux 2 Jenkins Slave') { steps { script {build_image('jenkins_slave.json')}}}
                stage('Build Kali Linux Jenkins Slave') { steps { script {build_image('jenkins_slave_kali.json')}}}
            }
        }

        stage('Build Centos Docker AMI') {
            parallel {
                stage('Build Centos Docker') { steps { script {build_image('centos_docker.json')}}}
            }
        }

        stage('Build Centos Docker Dependant AMIS') {
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
