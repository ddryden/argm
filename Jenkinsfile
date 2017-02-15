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
    sh "./install_debian_deps.sh"

    stage "Make build"
    sh 'make build'

    stage "install"
    sh 'sudo make install'

    stage "Test"
    sh 'make installcheck'

    stage "Build Debian Package"
    sh 'makedeb.sh'

}

