pipeline {
	agent any
	
	environment {
		DOCKER_IMAGE_NAME = "paulogesualdo/train-schedule"
	}

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
					
					echo "Building Docker image"
					app = docker.build("paulogesualdo/train-schedule")
					
					// Check if docker image was build correctly. Not working, troubleshooting in progress
					/*
					echo "Checking Docker image"
					app.inside {
						sh 'echo ${curl localhost:8080}'
					}
					*/
				}
			}
		}
		
		stage('Push Docker Image') {
			when {
				branch 'master'
			}
			steps {
				script {
					
					echo "Pushing Docker image"
					docker.withRegistry('https://registry.hub.docker.com', 'docker_hub_login') {
						app.push("${env.BUILD_NUMBER}")
						app.push("latest")
					}
				}
			}
		}
		
		// Instructions to deploy to a staging environment
		/*
		stage('Deploy to staging') {
			
			when {
				branch 'master'
			}
			
			steps {
				withCredentials ([usernamePassword(credentialsId: 'webserver_login', usernameVariable: 'USERNAME',passwordVariable: 'USERPASS')]) {
					
					script {

						echo "Executing a shell command on the staging machine to pull the docker image from Docker Hub"
						sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$staging_hostname \"sudo docker pull paulogesualdo/train-schedule:${env.BUILD_NUMBER}\""
						
						// Prevent the pipeline from failing if either of the commands below fail, because it is expected that they fail sometimes
						try {
							
							echo "Executing a shell command on the staging machine to stop the train-schedule container if it is running"
							sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$staging_hostname \"sudo docker stop train-schedule\""
							
							echo "Executing a shell command on the staging machine to remove the train-schedule container if it exists"
							sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$staging_hostname \"sudo docker rm train-schedule\""

						} catch (err) {
							echo: 'caught error $err'
						}

						echo "Executing a shell command on the staging machine to restart the container now and always if it fails"
						sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$staging_hostname \"sudo docker run --restart always --name train-schedule -p 8080:8080 -d paulogesualdo/train-schedule:${env.BUILD_NUMBER}\""

						// Instructions to deploy directly to a virtual machine, not a container
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
					}
				}
			}
		}
		*/
		
		stage('Deploy to production') {
			
			when {
				branch 'master'
			}
			
			steps {
				
				// Ask for a user input before deployment (deactivated)
				// input 'Does the staging environment look OK?'
				
				milestone(1)

				withCredentials([file(credentialsId: 'my-kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                        # Set the KUBECONFIG environment variable
                        export KUBECONFIG="${KUBECONFIG}"
						
						# Apply Kubernetes manifests
						kubectl apply -f train-schedule-kube.yml

						# Verify the deployment
						kubectl get deployments train-schedule-deployment
                    '''
                }

				// Instructions to deploy directly to container
				/*
				withCredentials ([usernamePassword(credentialsId: 'webserver_login', usernameVariable: 'USERNAME',passwordVariable: 'USERPASS')]) {
					
					script {

						echo "Executing a shell command on the production machine to pull the docker image from Docker Hub"
						sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$prod_hostname \"sudo docker pull paulogesualdo/train-schedule:${env.BUILD_NUMBER}\""
						
						// Prevent the pipeline from failing if either of the commands below fail, because it is expected that they fail sometimes
						try {
							
							echo "Executing a shell command on the production machine to stop the train-schedule container if it is running"
							sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$prod_hostname \"sudo docker stop train-schedule\""
							
							echo "Executing a shell command on the production machine to remove the train-schedule container if it exists"
							sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$prod_hostname \"sudo docker rm train-schedule\""

						} catch (err) {
							echo: 'caught error $err'
						}

						echo "Executing a shell command on the production machine to restart the container now and always if it fails"
						sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$prod_hostname \"sudo docker run --restart always --name train-schedule -p 8080:8080 -d paulogesualdo/train-schedule:${env.BUILD_NUMBER}\""

						
						// Instructions to deploy directly to a virtual machine, not a container
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
					}
				}
				*/
			}
		}
	}
}