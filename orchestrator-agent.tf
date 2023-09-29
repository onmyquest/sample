module "fargate-orchestrator-agent" {
  source          = "sysdiglabs/fargate-orchestrator-agent/aws"
  version         = "0.3.1"

  name             = "${var.name}-orchestrator"

  vpc_id           = var.vpc_id
  subnets          = var.subnets

  assign_public_ip = true  # if using Internet Gateway

  collector_host   = var.collector_host
  collector_port   = var.collector_port
  access_key       = var.sysdig_access_key
  #access_key       = "arn:aws:secretsmanager:us-east-1:059797578166:secret:giri-sysdig-json-EJCDBF:SysdigAccessKey::"
  check_collector_certificate = "false"
}