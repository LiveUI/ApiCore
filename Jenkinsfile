pipeline {
  agent none
  options {
    timeout(time: 15, unit: 'MINUTES')
  }

  stages {
    stage('Builds') {
        parallel {
            stage('Build Linux') {
              agent {
                label 'mac'
              }
              when {
                anyOf {
                  branch 'master'
                }
              }
              steps {
                script {
                  sh 'swift build --configuration debug'
                }
              }
            }

            stage('Test Linux') {
              agent any
              when {
                anyOf {
                  branch 'master'
                }
              }
              steps {
                script {
                  sh './test.sh'
                }
              }
            }
        }
    }
  }
}
