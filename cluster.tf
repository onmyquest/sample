resource "aws_ecs_cluster" "my_cluster" {
  name = "${var.name}-ecs"
}

resource "aws_cloudwatch_log_group" "my_logs" {
  name = "${var.name}-logs"
}

resource "aws_security_group" "my_security_group" {
  description = "Allow workload to reach internet"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "my_egress_rule" {
  type              = "egress"
  protocol          = "all"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my_security_group.id
}

resource "aws_iam_role" "my_execution_role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

#####
# Create ECS Task
#####

resource "aws_ecs_task_definition" "my_task_definition" {
  family             = "${var.name}-workload"
  execution_role_arn = aws_iam_role.my_execution_role.arn

  cpu                      = "256"
  memory                   = "1024"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  container_definitions = data.sysdig_fargate_workload_agent.instrumented.output_container_definitions
}

#####
# Deploy app on ECS cluster
#####

resource "aws_ecs_service" "my_service" {
  name = "${var.name}-service"

  cluster          = aws_ecs_cluster.my_cluster.id
  task_definition  = aws_ecs_task_definition.my_task_definition.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.my_security_group.id]
    assign_public_ip = true
  }
}