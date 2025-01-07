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
		
		stage('Build Docker Image') {
			when {
				branch 'master'
			}
			steps {
				script {
					app = docker.build("paulogesualdo/train-schedule")
					app.inside {
						sh 'echo ${curl localhost:8080}'
					}
				}
			}
		}
		
		stage('Push Docker Image') {
			when {
				branch 'master'
			}
			steps {
				script {
					docker.withRegistry('https://registry.hub.docker.com', 'docker_hub_login') {
						app.push("${env.BUILD_NUMBER}")
						app.push("latest")
					}
				}
			}
		}
		
		stage('Deploy to staging') {
			
			when {
				branch 'master'
			}
			
			steps {
				withCredentials ([usernamePassword(credentialsId: 'webserver_login', usernameVariable: 'USERNAME',passwordVariable: 'USERPASS')]) {
					
					// Execute a shell command on the staging machine to pull the docker image from Docker Hub
					sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$staging_hostname \"docker pull paulogesualdo/train-schedule:${env.BUILD_NUMBER}\""
					
					// Prevent the pipeline from failing if either of the commands below fail, because it is expected that they fail sometimes
					try {
						
						// Execute a shell command on the staging machine to stop the train-schedule container if it is running
						sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$staging_hostname \"docker stop train-schedule\""
						
						// Execute a shell command on the staging machine to remove the train-schedule container if it exists
						sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$staging_hostname \"docker rm train-schedule\""

					} catch (err) {
						echo: 'caucht error $err'
					}

					// Execute a shell command on the staging machine to reestart the container now and always if it fails
					sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$staging_hostname \"docker run --restart always --name train-schedule -p 8080:8080 -d paulogesualdo/train-schedule:${env.BUILD_NUMBER}\""

					
					// Instructions to deploy directly to a virtual machine, not a container
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
										execCommand: 'sudo systemctl stop train-schedule && sudo rm -rf /opt/trainSchedule/* && sudo unzip /tmp/trainSchedule.zip -d /opt/trainSchedule && sudo systemctl start train-schedule'
									)
								]
							)
						]
					)
					*/
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
					
					// Execute a shell command on the production machine to pull the docker image from Docker Hub
					sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$prod_hostname \"docker pull paulogesualdo/train-schedule:${env.BUILD_NUMBER}\""
					
					// Prevent the pipeline from failing if either of the commands below fail, because it is expected that they fail sometimes
					try {
						
						// Execute a shell command on the production machine to stop the train-schedule container if it is running
						sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$prod_hostname \"docker stop train-schedule\""
						
						// Execute a shell command on the production machine to remove the train-schedule container if it exists
						sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$prod_hostname \"docker rm train-schedule\""

					} catch (err) {
						echo: 'caucht error $err'
					}

					// Execute a shell command on the production machine to reestart the container now and always if it fails
					sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$prod_hostname \"docker run --restart always --name train-schedule -p 8080:8080 -d paulogesualdo/train-schedule:${env.BUILD_NUMBER}\""

					
					// Instructions to deploy directly to a virtual machine, not a container
					/*
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
										execCommand: 'sudo systemctl stop train-schedule && sudo rm -rf /opt/trainSchedule/* && sudo unzip /tmp/trainSchedule.zip -d /opt/trainSchedule && sudo systemctl start train-schedule'
									)
								]
							)
						]
					)
					*/
				}
			}
		}
	}
}
