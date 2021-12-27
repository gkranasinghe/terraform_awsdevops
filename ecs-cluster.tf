resource "aws_ecs_cluster" "bluegreen-cluster" {
  name = "bluegreen-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}



