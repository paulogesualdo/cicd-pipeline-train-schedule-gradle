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
					echo "Transferring build file to the machine"
					sh 'sshpass -p "$USERPASS" scp /dist/trainSchedule.zip $USERNAME@3.14.133.134:/opt/'
					/*
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
										execCommand: 'sudo /usr/bin/systemctl stop train-schedule && rm -rf /opt/trainSchedule/* && unzip /tmp/trainSchedule.zip -d /opt/trainSchedule && sudo /usr/bin/systemctl start train-schedule'
									)
								]
							)
						]
					)
					*/
				}
			}
		}
		/*
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
		*/
	}
}
