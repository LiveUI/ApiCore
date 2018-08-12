pipeline {
  agent none
  options {
    timeout(time: 15, unit: 'MINUTES')
  }

  stages {
    stage('Builds') {
        parallel {
            stage('Build MacOS') {
              agent {
                label 'xcode'
              }
              when {
                anyOf {
                  branch 'master'
                }
              }
              steps {
                script {
                  sh 'swift test'
                }
              }
            }

            stage('Build Linux') {
              agent any
              when {
                anyOf {
                  branch 'master'
                }
              }
              steps {
                script {
                  sh 'docker-compose -f docker-compose.test.yml up --abort-on-container-exit'
                }
              }
            }
        }
    }
  }
}
