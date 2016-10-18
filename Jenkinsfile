#!groovy

pipeline {
  stages {
    stage("build") {
      timeout(time: 5, units: "MINUTES"){
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
        sh 'make test'
      }
    }

    stage("publish debian packages") {
      timeout(timeout(time: 5, units: "MINUTES") {
        sh 'make publish'
      }
    }
  }

}
