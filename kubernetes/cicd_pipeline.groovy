pipeline {
agent any
stages {
  stage ('Repo Clone'){
  steps {
      dir('/var/lib/jenkins/importio'){
      git branch: "${params.branch}", url: "https://api:x-oauth-basic@github.com/ghazimabdullah/importio_test"
      }
  }
  }
  stage ('Docker build'){
  steps {
      dir('/var/lib/jenkins/importio'){
          script {
              def dockerfile = './importio_test/application/Dockerfile'
              docker.build("express", ". --no-cache")
            }
          }
      }
  }
    stage ('ECR Push'){
    steps {
      dir('/var/lib/jenkins/importio'){
          script {
      docker.withRegistry('444444000111.dkr.ecr.eu-west-2.amazonaws.com', 'ecr:eu-west-2:importio') {
      docker.image("express").push('latest')
        }
      }
      }
  }
  }
  
  stage('EKS Push'){
  steps {
      dir('/var/lib/jenkins/importio'){
          sh "aws eks update-kubeconfig --name "+"${params.cluster}"
          sh "kubectl apply -f ./importio_test/kubernetes/deployment.yml"
          sh "kubectl apply -f ./importio_test/kubernetes/service.yaml"
          sh "kubectl rollout restart deployment.apps/express-deployment"
      }
  }
  }
}
  post {
      failure {
          slackSend channel: "${params.channel}", color: "danger", message: "Pipeline failed"
      }
      success {
          slackSend channel: "${params.channel}", color: "good", message: "Pipeline finished successfully"
      }
  }
  }