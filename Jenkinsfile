#!/usr/bin/env groovy
def PROFILES = "${env.PROFILES}".split(" ")
def LOGFILES

pipeline {
    options {
        timeout(time: 2, unit: 'HOURS')
        timestamps()
    }
    agent { label "${env.SLAVES}"}
    stages {
        stage('Build, run') {
            steps {
                //parallelTasksNode ()
                parallelTasksDynamic ()
            }
        }

        stage ('Publish Html Report'){
            steps {
                script {
                    echo "===== UNSTASH  Test Result ====="
                    for (y in PROFILES) {
                        def service_profile = y
                        unstash "report-${service_profile}"
                        echo "Service-profile: ${service_profile}"
                        
                        // Rename result files
                        dir ('TAF/testArtifacts/reports/edgex/') {
                            sh "mv log.html ${service_profile}-log.html"
                            sh "mv report.html ${service_profile}-report.html"
                            // sh "mv result.xml ${service_profile}-result.xml"
                        }
                    }

                    dir ('TAF/testArtifacts/reports/edgex/') {
                        LOGFILES= sh (
                            script: 'ls *-log.html | sed ":a;N;s/\\n/,/g;ta"',
                            returnStdout: true
                        )
                    }
                }
                
                echo 'Publish....'
                publishHTML(
                    target: [
                        allowMissing: false,
                        keepAll: false,
                        reportDir: "TAF/testArtifacts/reports/edgex",
                        reportFiles: "${LOGFILES}",
                        reportName: "EdgeX Taf Report"]
                )

                junit "TAF/testArtifacts/reports/edgex/**.xml"
            }
        }
    }
}

def parallelTasksDynamic () {
    PROFILES = "${env.PROFILES}".split()
    def runprofilestage = [:]
    echo "Profile Length : " + PROFILES.length
    for (x in PROFILES) {
        def service_profile = x
        runprofilestage["Run Test For ${service_profile}"]= {
            node("${env.SLAVES}") {
                checkout scm
                
                stage ("Run ${service_profile} Test Cases"){
                    script {

                        sh "docker run --rm --network host -v ${env.WORKSPACE}:${env.WORKSPACE} -w ${env.WORKSPACE} --privileged \
                            -v /var/run/docker.sock:/var/run/docker.sock nexus3.edgexfoundry.org:10003/docker-edgex-taf-common:0.0.1 \
                            --exclude Skipped -u . -p ${service_profile}"
                    }
                }
                echo "===== STASH Test Result ====="
                stash name: "report-${service_profile}", includes: "TAF/testArtifacts/reports/edgex/*"
            }
        }
    }
    parallel runprofilestage
}

def parallelTasksNode () {
    PROFILES = "${env.PROFILES}".split()
    def SLAVES = "${env.SLAVES}".split()
    def maps = (0..<Math.min(PROFILES.size(), SLAVES.size())).collect { i -> [service_profile: PROFILES[i], slave: SLAVES[i]] }
    def runprofilestage = [:]
    for (item in maps) {
        def service_profile = item.service_profile
        def slave = item.slave
        runprofilestage["Run Test For ${service_profile}"]= { 
            node("${slave}") {
                checkout scm
                
                stage ("Run Test Cases"){
                    script {
                        sh "docker run --rm --network host -v ${env.WORKSPACE}:${env.WORKSPACE} -w ${env.WORKSPACE} \
                            -v /var/run/docker.sock:/var/run/docker.sock cherrycl/edgex-taf:1.0.0-common \
                            --exclude Skipped -u . -p ${service_profile}"
                    }
                }
                echo "===== STASH Test Result ====="
                stash name: "report-${service_profile}", includes: "TAF/testArtifacts/reports/edgex/*"
            }
        }
    }
    parallel runprofilestage
}
