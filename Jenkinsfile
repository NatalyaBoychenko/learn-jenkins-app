pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '1851c2d5-ea7d-4301-b061-c4bdef3be8b8'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        REACT_APP_VERSION = "1.0.$BUILD_ID"
    }

    stages {


        stage('AWS') {
            agent {
                docker {
                    image 'amazon/aws-cli'
                    args "--entrypoint=''"
                }
            }
            steps {
                sh '''
                    aws --version
                '''
            }
        }

        
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                echo 'Small change'
                    ls -la
                    node --version
                    npm --version
                    # add all necessary dependencies to run project and build project
                    npm ci
                    npm run build
                    ls -la
                '''
            }
        }
        

        stage('Tests') {
            parallel {

                stage('Unit tests') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            test -f build/index.html
                            npm test
                        '''
                    }
                    post {
                    always {
                        junit 'jest-results/junit.xml'
                    }
                    }
                }

                stage('E2E') {
                    agent {
                        docker {
                            image 'my-playwright'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            serve -s build &
                            sleep 10
                            npx playwright test  --reporter=html
                        '''
                    }
                    post {
                    always {
                        publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright E2E', reportTitles: '', useWrapperFileDirectly: true])
                    }
                    }
                }
            }
        }

     /*   stage('Deploy staging') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm install netlify-cli node-jq
                    node_modules/.bin/netlify --version
                    echo "Deploying to staging Site ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build --json > deploy-output.json
                '''
                script {
                    env.STAGING_URL = sh(script: "node_modules/.bin/node-jq -r '.deploy_url' deploy-output.json", returnStdout: true)
                }
            }
        }    */

         stage('Deploy staging') {
                    agent {
                        docker {
                            /*
                            // we use this if we haven't Dockerfile
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                            */
                            image 'my-playwright'
                            reuseNode true
                        }
                    }

                    environment {
                        CI_ENVIRONMENT_URL = 'SOME_VAR'
                    }
                    /*
                    if we don't use Docker file we must add the full path to the current file: node_modules/.bin/netlify --version
                    */
                    steps {
                        sh '''
                        netlify --version
                        echo "Deploying to staging Site ID: $NETLIFY_SITE_ID"
                        netlify status
                        netlify deploy --dir=build --json > deploy-output.json
                        CI_ENVIRONMENT_URL=$(jq -r '.deploy_url' deploy-output.json)
                        npx playwright test --reporter=html
                        '''
                    }
                    post {
                    always {
                        junit 'jest-results/junit.xml'
                        publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Staging E2E', reportTitles: '', useWrapperFileDirectly: true])
                    }
                    }
                }

         /* 
         // approval is needed only for contin delivered
         stage('Approval') {
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    input message: 'Are u sure u want to deploy?', ok: 'Yes, I\'m sure. Let\'s deploy!'
                }
            }
        }     */


     /*   stage('Deploy prod') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm install netlify-cli
                    node_modules/.bin/netlify --version
                    echo "Deploying to production Site ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build --prod
                '''
            }
        } */

        stage('Deploy prod') {
                    agent {
                        docker {
                            image 'my-playwright'
                            reuseNode true
                        }
                    }

                    environment {
                        CI_ENVIRONMENT_URL = 'https://glittering-naiad-3241c2.netlify.app'
                    }
                    steps {
                        sh '''
                        netlify --version
                        echo "Deploying to production Site ID: $NETLIFY_SITE_ID"
                        netlify status
                        netlify deploy --dir=build --prod
                            npx playwright test --reporter=html
                        '''
                    }
                    post {
                    always {
                        junit 'jest-results/junit.xml'
                        publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Prod E2E', reportTitles: '', useWrapperFileDirectly: true])
                    }
                    }
                }
    }

}
