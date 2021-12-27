resource "aws_codedeploy_app" "bluegreen-app" {
  compute_platform = "ECS"
  name             = "bluegreen-app"
}