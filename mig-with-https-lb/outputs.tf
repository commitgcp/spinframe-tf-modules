output "load_balancer_ip" {
  value       = module.lb_http.external_ip
  description = "The external IP of the HTTP(s) Load Balancer."
}

output "instance_group" {
  value       = module.mig.instance_group
  description = "The URL of the Managed Instance Group."
}
