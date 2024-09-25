pipeline {
  agent any
    stages {
        stage ('Build') {
            steps {
                sh '''#!/bin/bash
		# This  creates the python  virtual environment
                python3.9 -m venv venv
                
		# This activates the python virtual environment
		source venv/bin/activate

		# This installs any dependencies
                pip install pip --upgrade
                pip install -r requirements.txt
                '''
            }
        }
        stage ('Test') {
            steps {
                sh '''#!/bin/bash
                source venv/bin/activate
                py.test ./tests/unit/ --verbose --junit-xml test-reports/results.xml
                '''
            }
            post {
                always {
                    junit 'test-reports/results.xml'
                }
            }
        }
      stage ('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
      stage ('Deploy') {
            steps {
		sshagent(credentials: ['web-server-ssh-key']) {
 		   sh "ssh -o StrictHostKeyChecking=no ubuntu@10.0.6.249 'source /home/ubuntu/setup.sh'"
		} 
            }
        }
    }
}
