provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

module "single-account-cspm" {
  providers = {
    aws = aws.us-east-1
  }
  source           = "draios/secure-for-cloud/aws//modules/services/trust-relationship"
  role_name        = "sysdig-secure-j2rx"
  trusted_identity = "arn:aws:iam::761931097553:role/us-east-1-production-secure-assume-role"
  external_id      = "37db198a94d1b7770f36244f1fda20ca"
}

module "single-account-threat-detection-us-east-1" {
  providers = {
    aws = aws.us-east-1
  }
  source                  = "draios/secure-for-cloud/aws//modules/services/event-bridge"
  target_event_bus_arn    = "arn:aws:events:us-east-1:761931097553:event-bus/us-east-1-production-falco-1"
  trusted_identity        = "arn:aws:iam::761931097553:role/us-east-1-production-secure-assume-role"
  external_id             = "37db198a94d1b7770f36244f1fda20ca"
  name                    = "sysdig-secure-cloudtrail-tgf2"
  deploy_global_resources = true
}


