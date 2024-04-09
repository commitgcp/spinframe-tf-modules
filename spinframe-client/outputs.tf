output "load_balancer_ip" {
  value       = module.mig_with_https_lb.load_balancer_ip
  description = "The external IP of the HTTP(s) Load Balancer."
}

output "instance_group" {
  value       = module.mig_with_https_lb.instance_group
  description = "The URL of the Managed Instance Group."
}
