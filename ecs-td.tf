resource "aws_ecs_task_definition" "service-td" {
  family = "service-td"
  container_definitions = jsonencode([
    {
      "name" : "sample-app",
      "image" : "httpd:2.4",
      "portMappings" : [
        {
          "containerPort" : 80,
          "hostPort" : 80,
          "protocol" : "tcp"
        }
      ],
      "essential" : true,
      "entryPoint" : ["sh", "-c"],
      "command" : [
        "/bin/sh -c \"echo '<html> <head> <title>Amazon ECS Sample App</title> <style>body {margin-top: 40px; background-color: #1874cd;} </style> </head><body> <div style=color:white;text-align:center> <h1>Amazon ECS Sample App</h1> <h2>Congratulations!</h2> <p>Your application is now running on a container in Amazon ECS.</p> </div></body></html>' >  /usr/local/apache2/htdocs/index.html && httpd-foreground\""
      ]
    }
  ])
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  task_role_arn            = "arn:aws:iam::240202668905:role/CodeDeployServiceRole"


}



resource "null_resource" "appspec-file" {
  provisioner "local-exec" {
    command = <<-EOT
    cat >appspec.yml <<EOF
version: 0.0
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: $TD_ARN
        LoadBalancerInfo:
          ContainerName: 'sample-app'
          ContainerPort: 80

EOF
  EOT

    environment = {
       TD_ARN = "${aws_ecs_task_definition.service-td.arn}"
    }
  }
}