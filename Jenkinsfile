pipeline {
	agent any
	stages {
		stage('Build') {
			steps {
				echo "Running build automation"
				sh './gradlew buil --no-daemon'
				archiveArtifacts artifacts: 'dist/trainSchedule.zip'
			}
		}
		stage('Deploy to staging') {
			when {
				branch 'master'
			}
			steps {
				withCredentials ([usernamePassword(credentialsId: 'webserver_login', usernameVariable: username,passwordVariable: password)]) {
					sshPublisher (
						failOnError: true, 
						continueOnError: false,
						publishers: [
							sshPublisherDesc(
								configName: 'staging-server',
								sshCredentials: [
									username: "$username",
									encryptedPassphrase: "$password"
								],
								transfers: [
									sshTransfer(
										sourceFiles: 'dist/trainSchedule.zip',
										removePrefix: 'dist/'
										remoteDirectory: '/tmp',
										execCommand: 'sudo /usr/bin/systemctl stop train-schedule && rm -rf /opt/train-schedule/* && unzip /tmp/trainSchedule.zip -d /opt/train-schedule && sudo /usr/bin/systemctl start train-schedule'
									)
								]
							)
						]
					)
				}
			}
		}
		stage('Deploy to production') {
			when {
				branch 'master'
			}
			steps {
				input 'Does the staging environment look OK?'
				milestone(1)
				withCredentials ([usernamePassword(credentialsId: 'webserver_login', usernameVariable: username,passwordVariable: password)]) {
					sshPublisher (
						failOnError: true, 
						continueOnError: false,
						publishers: [
							sshPublisherDesc(
								configName: 'production-server',
								sshCredentials: [
									username: "$username",
									encryptedPassphrase: "$password"
								],
								transfers: [
									sshTransfer(
										sourceFiles: 'dist/trainSchedule.zip',
										removePrefix: 'dist/'
										remoteDirectory: '/tmp',
										execCommand: 'sudo /usr/bin/systemctl stop train-schedule && rm -rf /opt/train-schedule/* && unzip /tmp/trainSchedule.zip -d /opt/train-schedule && sudo /usr/bin/systemctl start train-schedule'
									)
								]
							)
						]
					)
				}
			}
		}
	}
}
