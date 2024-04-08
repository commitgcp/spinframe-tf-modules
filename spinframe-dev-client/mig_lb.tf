module "mig_with_https_lb" {
  source = "git::https://github.com/commitgcp/spinframe-tf-modules.git//mig-with-https-lb?ref=main"

  project_id = var.project_id
  region     = var.region
  name       = var.name
  domains    = var.domains

  instance_template = var.instance_template

  managed_instance_group = var.managed_instance_group

  load_balancer = var.load_balancer

  load_balancer_backend = var.load_balancer_backend
}