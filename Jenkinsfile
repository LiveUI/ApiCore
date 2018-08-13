pipeline {
  agent none
  options {
    timeout(time: 15, unit: 'MINUTES')
  }

  stages {
    stage('Builds') {
        parallel {
            stage('Test Linux') {
              agent {
                label 'master'
              }
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
