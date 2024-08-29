module "static_egress_ip" {
    source = "github.com/cloudninedigital/cnd-terraform//static_egress_ip"
    name = "sftp-access"
    project = var.project
    region = var.region
}

output "vpc_connector" {
  value = module.static_egress_ip.vpc_connector
}