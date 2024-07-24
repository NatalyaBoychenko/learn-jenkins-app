pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '1851c2d5-ea7d-4301-b061-c4bdef3be8b8'
    }

    stages {
        
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
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
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            npm install serve
                            node_modules/.bin/serve -s build &
                            sleep 40
                            npx playwright test --reporter=html
                        '''
                    }
                    post {
                    always {
                        junit 'jest-results/junit.xml'
                        publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                    }
                    }
                }
            }
        }

        stage('Deploy') {
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
                '''
            }
        } 
    }

}
