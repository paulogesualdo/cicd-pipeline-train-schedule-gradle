pipeline {
	
	agent any

	environment {
		CANARY_REPLICAS = 0
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
		
		// Deploy to a staging environment directly to a virtual machine, not Docker neither Kubernetes
		/*
		stage('Deploy to staging - VM') {
			
			when {
				branch 'master'
			}
			
			steps {
				withCredentials ([usernamePassword(credentialsId: 'webserver_login', usernameVariable: 'USERNAME',passwordVariable: 'USERPASS')]) {
					
					script {
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

		// Deploy to a staging environment on Docker, not directly to the virtual machine neither Kubernetes
		/*
		stage('Deploy to staging - Docker') {
			
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
					}
				}
			}
		}
		*/

		// Deploy to a production environment directly to a virtual machine, not Docker neither Kubernetes
		/*
		stage('Deploy to production - VM') {
			
			when {
				branch 'master'
			}
			
			steps {
				
				// Ask for a user input before deployment
				input 'Does the staging environment look OK?'
				
				milestone(1)

				withCredentials ([usernamePassword(credentialsId: 'webserver_login', usernameVariable: 'USERNAME',passwordVariable: 'USERPASS')]) {
					
					script {

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
			}
		}
		*/

		// Deploy to a production environment on Docker, not directly to the virtual machine neither Kubernetes
		/*
		stage('Deploy to production - Docker') {
			
			when {
				branch 'master'
			}
			
			steps {
				
				// Ask for a user input before deployment (deactivated)
				// input 'Does the staging environment look OK?'
				
				milestone(1)

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

					}
				}
			}
		}
		*/

		// Deploy to canary test environment on Kubernetes, not directly to the virtual machine neither Docker
		stage('Canary Deploy - Kubernetes') {
			
			when {
				branch 'master'
			}
			
			environment {
				CANARY_REPLICAS = 1
			}
			
			steps {
				
				withCredentials([file(credentialsId: 'my-kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                        # Set the KUBECONFIG environment variable
                        export KUBECONFIG="${KUBECONFIG}"
						
						# Apply Kubernetes manifests
						envsubst < train-schedule-kube-canary.yml | kubectl apply -f -

						# Verify the deployment
						kubectl get deployments train-schedule-deployment-canary
                    '''
                }
			}
		}

		stage('Smoke Test') {
			when {
				branch 'master'
			}
			steps {
				script {
					
					// Pause to check the canary deployment for troubleshooting reasons
					input 'Pause to check canary deployment'
					
					sleep (time: 5)
					
					def response = sh (
						script: "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$kube_node_hostname 'curl -s -o /dev/null -w \"%{http_code}\" http://${kube_node_hostname}:8083/'",
						returnStdout: true
					).trim()
					
					if (response != '200') {
						error("Smoke test against canary deployment failed")
					}
				}
			}
		}
		
		// Deploy to a production environment on Kubernetes, not directly to the virtual machine neither Docker
		stage('Deploy to production - Kubernetes') {
			
			when {
				branch 'master'
			}
			
			steps {
				
				milestone(1)

				withCredentials([file(credentialsId: 'my-kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                        # Set the KUBECONFIG environment variable
                        export KUBECONFIG="${KUBECONFIG}"

						# Apply the standard Kubernetes manifests
						kubectl apply -f train-schedule-kube.yml

						# Verify the deployment
						kubectl get deployments train-schedule-deployment
                    '''
                }
			}
		}
	}

	post {
		cleanup {
			
			withCredentials([file(credentialsId: 'my-kubeconfig', variable: 'KUBECONFIG')]) {
				sh '''
					# Set the KUBECONFIG environment variable
					export KUBECONFIG="${KUBECONFIG}"
					
					# Apply the canary Kubernetes manifests reducing the canary replicas to zero
					envsubst < train-schedule-kube-canary.yml | kubectl apply -f -
				'''
			}
		}
	}
}