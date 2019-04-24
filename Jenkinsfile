/*
 * This program and the accompanying materials are made available under the terms of the
 * Eclipse Public License v2.0 which accompanies this distribution, and is available at
 * https://www.eclipse.org/legal/epl-v20.html
 *
 * SPDX-License-Identifier: EPL-2.0
 *
 * Copyright Contributors to the Zowe Project.
 */

/**
 * These 2 build parameters are only required for running integration test
 */
def opts = []
// define custom build parameters
def customParameters = []
customParameters.push(booleanParam(
  name: 'FETCH_PARAMETER_ONLY',
  description: 'By default, the pipeline will exit just for fetching parameters.',
  defaultValue: true
))
customParameters.push(string(
  name: 'LIBRARY_BRANCH',
  description: 'Jenkins library branch to test',
  defaultValue: '',
  trim: true
))
opts.push(parameters(customParameters))

// set build properties
properties(opts)

/**
 * This check is only required for running integration test
 */
if (params.FETCH_PARAMETER_ONLY) {
    currentBuild.result = 'NOT_BUILT'
    error "Prematurely exit after fetching parameters."
}

node('ibm-jenkins-slave-nvm') {
    /**
     * This section is only required for running integration test.
     *
     * In real consumption of library, we should use default library branch. For
     * example:
     *
     * def lib = library("jenkins-library").org.zowe.jenkins_shared_library
     */
    def branch = 'master'

    if (params.LIBRARY_BRANCH) {
        branch = params.LIBRARY_BRANCH
    } else if (env.CHANGE_BRANCH) {
        branch = env.CHANGE_BRANCH
    } else if (env.BRANCH_NAME) {
        branch = env.BRANCH_NAME
    }

    echo "Jenkins library branch $branch will be used to build."
    def lib = library("jenkins-library@$branch").org.zowe.jenkins_shared_library

    def pipeline = lib.pipelines.nodejs.NodeJSPipeline.new(this)

    /**
     * These 2 build parameters are only required for running integration test
     */
    pipeline.addBuildParameters(customParameters)

    pipeline.admins.add("jackjia")
    pipeline.setPackageName('org.zowe.jenkins-library-test.nodejs')

    pipeline.configureArtifactory([
      url                        : 'https://gizaartifactory.jfrog.io/gizaartifactory',
      usernamePasswordCredential : 'GizaArtifactory',
    ])
    pipeline.configureGitHub([
      email                      : 'zowe.robot@gmail.com',
      usernamePasswordCredential : 'zowe-robot-github',
    ])
    pipeline.configurePublishRegistry([
      email                      : 'giza-jenkins@gmail.com',
      usernamePasswordCredential : 'giza-jenkins-basicAuth',
    ])
    pipeline.configureInstallRegistry([
      email                      : 'giza-jenkins@gmail.com',
      usernamePasswordCredential : 'giza-jenkins-basicAuth',
      registry                   : 'https://gizaartifactory.jfrog.io/gizaartifactory/api/npm/npm-local-release/',
      scope                      : 'zowe',
    ])

    pipeline.setup()

    // lint before build
    pipeline.createStage(
        name          : "Lint",
        isSkippable   : true,
        stage         : {
            sh 'npm run lint'
        },
        timeout: [time: 5, unit: 'MINUTES']
    )

    // we need npm build before test
    pipeline.build()

    def UNIT_TEST_ROOT = "__tests__/__results__"

    pipeline.test(
        name          : "Unit",
        operation     : {
            sh "npm run test:unit"
        },
        junit         : "${UNIT_TEST_ROOT}/unit/junit.xml",
        cobertura     : [
            // do not mark as UNSTABLE if not pass the requirement
            autoUpdateStability       : false,
            fileCoverageTargets       : '0, 0, 0',
            classCoverageTargets      : '0, 0, 0',
            methodCoverageTargets     : '0, 0, 0',
            lineCoverageTargets       : '0, 0, 0',
            conditionalCoverageTargets: '0, 0, 0',
            coberturaReportFile       : "${UNIT_TEST_ROOT}/unit/coverage/cobertura-coverage.xml"
        ],
        htmlReports   : [
            [dir: "${UNIT_TEST_ROOT}/jest-stare", files: "index.html", name: "Report: Jest Stare"],
            [dir: "${UNIT_TEST_ROOT}", files: "results.html", name: "Report: Unit Test"],
            [dir: "${UNIT_TEST_ROOT}/unit/coverage/lcov-report", files: "index.html", name: "Report: Code Coverage"],
        ],
    )

    // define we need publish stage
    pipeline.publish()

    // define we need release stage
    pipeline.release()

    pipeline.end()
}
