node('docker') {
    stage 'Checkout'
    checkout([
        $class: 'GitSCM',
        branches: scm.branches,
        doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
        extensions: scm.extensions + [[$class: 'CleanCheckout']],
        userRemoteConfigs: scm.userRemoteConfigs
    ])

    stage "Install deps"
    sh "mkdir -p output"
    sh "curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -"
    echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -sc`-pgdg main" | sudo tee -a /etc/apt/sources.list
    sudo apt-get update
    sudo /etc/init.d/postgresql stop
    sudo apt-get purge -y postgresql-common postgresql-client-common
    apt-cache search postgresql-server-dev

    stage "Make build"
    sh 'make build'

    stage "install"
    sh 'sudo make install'

    stage "Test"
    sh 'make installcheck'

    stage "Build Debian Package"
    sh 'makedeb.sh'

}

