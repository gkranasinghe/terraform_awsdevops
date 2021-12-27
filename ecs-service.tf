resource "aws_ecs_service" "service-bluegreen" {
  name            = "service-bluegreen"
  cluster         = aws_ecs_cluster.bluegreen-cluster.id
  task_definition = aws_ecs_task_definition.service-td.arn
  desired_count   = 1
  # iam_role        = aws_iam_role.CodeDeployServiceRole.arn
  # depends_on      = [aws_iam_role_policy.foo]

  launch_type        = "FARGATE"
  scheduling_strategy = "REPLICA"
 deployment_controller {
    type = "CODE_DEPLOY"
  }


  load_balancer {
    target_group_arn = aws_lb_target_group.bluegreentarget1.arn
    container_name   = "sample-app"
    container_port   = 80
  }
  platform_version = "LATEST"
  network_configuration {
   
      assign_public_ip = true
      security_groups = [aws_security_group.ecs-sg.id]
      subnets        = [aws_subnet.subnet-1a.id, aws_subnet.subnet-1b.id]
   
  }

}