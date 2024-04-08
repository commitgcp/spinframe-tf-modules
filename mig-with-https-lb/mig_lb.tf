# Create a Service Account
resource "google_service_account" "mig_sa" {
  project      = var.project_id
  account_id   = "${var.name}-sa"
  display_name = "Service Account for ${var.name} MIG"
}

resource "google_compute_managed_ssl_certificate" "default" {
  name = "${var.name}-cert"

  managed {
    domains = var.domains
  }
}

# Instance Template Configuration
module "instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 11.0"

  access_config                    = var.instance_template.access_config
  additional_disks                 = var.instance_template.additional_disks
  additional_networks              = var.instance_template.additional_networks
  alias_ip_range                   = var.instance_template.alias_ip_range
  auto_delete                      = var.instance_template.auto_delete
  automatic_restart                = var.instance_template.automatic_restart
  can_ip_forward                   = var.instance_template.can_ip_forward
  disk_encryption_key              = var.instance_template.disk_encryption_key
  disk_labels                      = var.instance_template.disk_labels
  disk_size_gb                     = var.instance_template.disk_size_gb
  disk_type                        = var.instance_template.disk_type
  enable_confidential_vm           = var.instance_template.enable_confidential_vm
  enable_nested_virtualization     = var.instance_template.enable_nested_virtualization
  enable_shielded_vm               = var.instance_template.enable_shielded_vm
  gpu                              = var.instance_template.gpu
  ipv6_access_config               = var.instance_template.ipv6_access_config
  labels                           = var.labels
  machine_type                     = var.instance_template.machine_type
  maintenance_interval             = var.instance_template.maintenance_interval
  metadata                         = var.instance_template.metadata
  min_cpu_platform                 = var.instance_template.min_cpu_platform
  name_prefix                      = "${var.name}-instance-template"
  network                          = var.network
  network_ip                       = var.instance_template.network_ip
  nic_type                         = var.instance_template.nic_type
  on_host_maintenance              = var.instance_template.on_host_maintenance
  preemptible                      = var.instance_template.preemptible
  project_id                       = var.project_id
  region                           = var.region
  resource_policies                = var.instance_template.resource_policies
  service_account                  = { email = google_service_account.mig_sa.email, scopes = toset([]) }
  source_image                     = var.instance_template.source_image
  source_image_family              = var.instance_template.source_image_family
  source_image_project             = var.instance_template.source_image_project
  spot                             = var.instance_template.spot
  spot_instance_termination_action = var.instance_template.spot_instance_termination_action
  stack_type                       = var.instance_template.stack_type
  startup_script                   = var.instance_template.startup_script
  subnetwork                       = var.instance_template.subnetwork
  tags                             = var.instance_template.tags
  threads_per_core                 = var.instance_template.threads_per_core
  total_egress_bandwidth_tier      = var.instance_template.total_egress_bandwidth_tier

  depends_on = [google_service_account.mig_sa]
}


# Managed Instance Group Configuration
module "mig" {
  source  = "terraform-google-modules/vm/google//modules/mig"
  version = "~> 11.1.0"

  project_id        = var.project_id
  hostname          = var.name
  region            = var.region
  instance_template = module.instance_template.self_link
  labels            = var.labels

  named_ports = [{ name = var.load_balancer_backend.backend_port_name, port = var.load_balancer_backend.backend_port }]

  # Attributes from the managed_instance_group object
  target_size               = var.managed_instance_group.target_size
  target_pools              = var.managed_instance_group.target_pools
  distribution_policy_zones = var.managed_instance_group.distribution_policy_zones
  update_policy             = var.managed_instance_group.update_policy
  health_check              = var.managed_instance_group.health_check

  autoscaling_enabled              = var.managed_instance_group.autoscaling_enabled
  max_replicas                     = var.managed_instance_group.max_replicas
  min_replicas                     = var.managed_instance_group.min_replicas
  cooldown_period                  = var.managed_instance_group.cooldown_period
  autoscaling_cpu                  = var.managed_instance_group.autoscaling_cpu
  autoscaling_metric               = var.managed_instance_group.autoscaling_metric
  autoscaling_lb                   = var.managed_instance_group.autoscaling_lb
  autoscaling_scale_in_control     = var.managed_instance_group.autoscaling_scale_in_control
  autoscaling_mode                 = var.managed_instance_group.autoscaling_mode
  distribution_policy_target_shape = var.managed_instance_group.distribution_policy_target_shape
  scaling_schedules                = var.managed_instance_group.scaling_schedules
  stateful_disks                   = var.managed_instance_group.stateful_disks
  stateful_ips                     = var.managed_instance_group.stateful_ips
  wait_for_instances               = var.managed_instance_group.wait_for_instances

}

# HTTPS Load Balancer Configuration using the terraform-google-lb-http module
module "lb_http" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "~> 10.2.0"

  project = var.project_id
  name    = "${var.name}-lb"
  labels  = var.labels

  backends = {
    default = {
      description = "Default backend"
      project     = var.project_id

      affinity_cookie_ttl_sec         = var.load_balancer_backend.affinity_cookie_ttl_sec
      cdn_policy                      = var.load_balancer_backend.cdn_policy
      compression_mode                = var.load_balancer_backend.compression_mode
      connection_draining_timeout_sec = var.load_balancer_backend.timeout_sec
      custom_request_headers          = var.load_balancer_backend.custom_request_headers
      custom_response_headers         = var.load_balancer_backend.custom_response_headers
      edge_security_policy            = var.load_balancer_backend.edge_security_policy
      enable_cdn                      = var.load_balancer_backend.enable_cdn
      groups = [
        {
          group                        = module.mig.instance_group
          balancing_mode               = "UTILIZATION"
          capacity_scaler              = 1.0
          description                  = "Instance group for the default backend"
          max_rate_per_instance        = null
          max_connections_per_instance = null
          max_utilization              = 0.8
        }
      ]
      health_check     = var.load_balancer_backend.http_health_check
      iap_config       = var.load_balancer_backend.iap_config
      log_config       = var.load_balancer_backend.log_config
      port             = var.load_balancer_backend.backend_port
      port_name        = var.load_balancer_backend.backend_port_name
      protocol         = var.load_balancer_backend.backend_protocol
      security_policy  = var.load_balancer_backend.security_policy
      session_affinity = var.load_balancer_backend.session_affinity
      timeout_sec      = var.load_balancer_backend.timeout_sec

    }
  }


  address                         = var.load_balancer.address
  certificate                     = var.load_balancer.certificate
  certificate_map                 = var.load_balancer.certificate_map
  create_address                  = var.load_balancer.create_address
  create_ipv6_address             = var.load_balancer.create_ipv6_address
  create_ssl_certificate          = var.load_balancer.create_ssl_certificate
  create_url_map                  = var.load_balancer.create_url_map
  enable_ipv6                     = var.load_balancer.enable_ipv6
  firewall_networks               = var.load_balancer.firewall_networks
  firewall_projects               = var.load_balancer.firewall_projects
  http_forward                    = var.load_balancer.create_http_forward
  http_port                       = var.load_balancer.http_forward_port
  https_port                      = var.load_balancer.https_port
  https_redirect                  = var.load_balancer.https_redirect # Set to true if HTTPS redirect is needed
  ipv6_address                    = var.load_balancer.ipv6_address
  load_balancing_scheme           = var.load_balancer.load_balancing_scheme
  managed_ssl_certificate_domains = var.load_balancer.managed_ssl_certificate_domains
  network                         = var.network
  private_key                     = var.load_balancer.private_key
  quic                            = var.load_balancer.quic
  random_certificate_suffix       = var.load_balancer.random_certificate_suffix
  server_tls_policy               = var.load_balancer.server_tls_policy
  ssl                             = var.load_balancer.ssl
  ssl_certificates                = [google_compute_managed_ssl_certificate.default.self_link]
  ssl_policy                      = var.load_balancer.ssl_policy
  target_service_accounts         = var.load_balancer.target_service_accounts
  target_tags                     = var.load_balancer.target_tags
  url_map                         = var.load_balancer.url_map

  depends_on = [google_compute_managed_ssl_certificate.default]
  # Additional configurations can be added as required
}