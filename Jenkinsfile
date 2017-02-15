#!groovy

pipeline {
  agent { label 'docker' }
  stages {
    stage("build") {
      timeout(time: 5, units: "MINUTES"){
        checkout scm
        sh 'make build'
      }
    }

    stage("install") {
      timeout(time: 5, units: "MINUTES"){
        sh 'sudo make install'
      }
    }

    stage("test") {
      timeout(time: 5, units: "MINUTES") {
        sh 'make installcheck'
      }
    }

    stage("publish debian packages") {
      timeout(time: 5, units: "MINUTES") {
        sh 'makedeb.sh'
      }
    }

  }

}

