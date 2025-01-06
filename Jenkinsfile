pipeline {
	agent any
	stages {
		stage('Build') {
			steps {
				echo "Running build automation"
				sh './gradlew build --no-daemon'
				archiveArtifacts artifacts: 'dist/trainSchedule.zip'
			}
		}
		stage('Deploy to staging') {
			when {
				branch 'master'
			}
			steps {
				withCredentials ([usernamePassword(credentialsId: 'webserver_login', usernameVariable: 'USERNAME',passwordVariable: 'USERPASS')]) {
					sshPublisher (
						failOnError: true, 
						continueOnError: false,
						publishers: [
							sshPublisherDesc(
								configName: 'staging-server',
								sshCredentials: [
									username: "$USERNAME",
									encryptedPassphrase: "$USERPASS"
								],
								transfers: [
									sshTransfer(
										sourceFiles: 'dist/trainSchedule.zip',
										removePrefix: 'dist/',
										remoteDirectory: '/tmp',
										execCommand: '
											echo "Stopping service"
											&&
											sudo /usr/bin/systemctl stop train-schedule 
											&&
											echo "Removing current project files"
											&&
											rm -rf /opt/trainSchedule/*
											&&
											echo "Unziping new project files"
											&&
											unzip /tmp/trainSchedule.zip -d /opt/trainSchedule
											&&
											echo "Starting services"
											&&
											sudo /usr/bin/systemctl start train-schedule'
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
				withCredentials ([usernamePassword(credentialsId: 'webserver_login', usernameVariable: 'USERNAME',passwordVariable: 'USERPASS')]) {
					sshPublisher (
						failOnError: true, 
						continueOnError: false,
						publishers: [
							sshPublisherDesc(
								configName: 'production-server',
								sshCredentials: [
									username: "$USERNAME",
									encryptedPassphrase: "$USERPASS"
								],
								transfers: [
									sshTransfer(
										sourceFiles: 'dist/trainSchedule.zip',
										removePrefix: 'dist/',
										remoteDirectory: '/tmp',
										execCommand: 'sudo /usr/bin/systemctl stop train-schedule && rm -rf /opt/trainSchedule/* && unzip /tmp/trainSchedule.zip -d /opt/trainSchedule && sudo /usr/bin/systemctl start train-schedule'
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
