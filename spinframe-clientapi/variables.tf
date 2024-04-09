######################
### GENERAL CONFIG ###
######################

variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The GCP region where resources will be created."
  type        = string
}

variable "name" {
  description = "The name prefix for all resources."
  type        = string
}

variable "labels" {
  description = "The labels to attach to resources created by this module."
  type        = map(string)
  default     = {}
}

variable "domains" {
  description = "Domains for which a managed SSL certificate will be valid."
  type        = list(string)
}

variable "network" {
  description = "Network for resources to be created in"
  type        = string
  default     = "default"
}

##########################
### END GENERAL CONFIG ###
##########################

#########################
### INSTANCE TEMPLATE ###
#########################

variable "instance_template" {
  description = <<-EOD
    Configuration for the instance template includes:
    - access_config: Access configurations, i.e., IPs via which the VM instance can be accessed via the Internet.
    - additional_disks: List of additional disk configurations.
    - alias_ip_range: An array of alias IP ranges for this network interface.
    - auto_delete: Whether the disk will be auto-deleted when the instance is deleted.
    - automatic_restart: Specifies whether the instance should be automatically restarted if it is terminated by Compute Engine.
    - can_ip_forward: Allow IP forwarding for the instances.
    - disk_encryption_key: The id of the encryption key that is stored in Google Cloud KMS to use to encrypt all the disks on this instance.
    - disk_labels: A map of labels to attach to the disk.
    - disk_size_gb: The size of the disk attached to each instance, specified in GB.
    - disk_type: The type of the disk attached to each instance.
    - gpu: GPU information. Type and count of GPU to attach to the instance template.
    - ipv6_access_config: IPv6 access configurations.
    - machine_type: The machine type to use for the compute instances.
    - maintenance_interval: Specifies the frequency of planned maintenance events.
    - metadata: Metadata key/value pairs to make available from within the compute instances.
    - min_cpu_platform: Specifies a minimum CPU platform.
    - network_ip: Private IP address to assign to the instance if desired.
    - on_host_maintenance: Instance availability Policy.
    - resource_policies: A list of self_links of resource policies to attach to the instance.
    - source_image: The source image for the disks attached to the compute instances.
    - source_image_family: The family of the source image for the disk.
    - source_image_project: The project of the source image for the disk.
    - stack_type: The stack type for this network interface to identify whether the IPv6 feature is enabled or not.
    - startup_script: The startup script to run on each compute instance.
    - subnetwork: The subnetwork to deploy to.
    - tags: A list of tags to attach to the compute instances.
  EOD

  type = object({
    access_config = optional(list(object({
      nat_ip       = string
      network_tier = string
    })), [])
    additional_disks = optional(list(object({
      device_name  = string
      disk_labels  = map(string)
      disk_name    = string
      disk_type    = string
      auto_delete  = bool
      boot         = bool
      disk_size_gb = number
      labels       = map(string)
    })), [])
    additional_networks = optional(list(object({
      network            = string
      subnetwork         = string
      subnetwork_project = string
      network_ip         = string
      nic_type           = string
      stack_type         = string
      queue_count        = number
      access_config = list(object({
        nat_ip       = string
        network_tier = string
      }))
      ipv6_access_config = list(object({
        network_tier = string
      }))
      alias_ip_range = list(object({
        ip_cidr_range         = string
        subnetwork_range_name = string
      }))
    })), [])
    alias_ip_range = optional(object({
      ip_cidr_range         = string
      subnetwork_range_name = string
    }), null)
    auto_delete                  = optional(bool, true)
    automatic_restart            = optional(bool, true)
    can_ip_forward               = optional(bool, false)
    disk_encryption_key          = optional(string, null)
    disk_labels                  = optional(map(string), {})
    disk_size_gb                 = optional(number, 10)
    disk_type                    = optional(string, "pd-standard")
    enable_confidential_vm       = optional(bool, false)
    enable_nested_virtualization = optional(bool, false)
    enable_shielded_vm           = optional(bool, false)
    gpu = optional(object({
      type  = string
      count = number
    }), null)
    ipv6_access_config = optional(list(object({
      network_tier = string
    })), [])
    machine_type         = optional(string, "e2-micro")
    maintenance_interval = optional(string, null)
    metadata             = optional(map(string), {})
    min_cpu_platform     = optional(string, null)
    network_ip           = optional(string, "")
    nic_type             = optional(string, null)
    on_host_maintenance  = optional(string, "MIGRATE")
    preemptible          = optional(bool, false)
    resource_policies    = optional(list(string), [])
    shielded_instance_config = optional(object({
      enable_secure_boot          = bool
      enable_vtpm                 = bool
      enable_integrity_monitoring = bool
      }), {
      enable_secure_boot          = false
      enable_vtpm                 = true
      enable_integrity_monitoring = true
    })
    source_image                     = optional(string, "debian-cloud/debian-9")
    source_image_family              = optional(string, null)
    source_image_project             = optional(string, null)
    spot                             = optional(bool, false)
    spot_instance_termination_action = optional(string, "STOP")
    stack_type                       = optional(string, null)
    startup_script                   = optional(string, "")
    subnetwork                       = optional(string, "")
    tags                             = optional(list(string), [])
    threads_per_core                 = optional(number, null)
    total_egress_bandwidth_tier      = optional(string, "DEFAULT")
  })
}


#############################
### END INSTANCE TEMPLATE ###
#############################

##############################
### MANAGED INSTANCE GROUP ###
##############################

variable "managed_instance_group" {
  description = <<-EOD
    Configuration for the Managed Instance Group includes:
    - autoscaling_cpu: Autoscaling based on CPU utilization.
    - autoscaling_enabled: Creates an autoscaler for the managed instance group.
    - autoscaling_lb: Autoscaling based on load balancing utilization.
    - autoscaling_metric: Autoscaling based on custom metric.
    - autoscaling_mode: Operating mode of the autoscaling policy.
    - autoscaling_scale_in_control: Autoscaling scale-in control parameters.
    - cooldown_period: The number of seconds that the autoscaler should wait before it starts collecting information from a new instance.
    - distribution_policy_target_shape: The shape to which the group converges.
    - distribution_policy_zones: The distribution policy, i.e., which zone(s) should instances be created in.
    - health_check: Health check configuration.
    - max_replicas: The maximum number of instances that the autoscaler can scale up to.
    - min_replicas: The minimum number of replicas that the autoscaler can scale down to.
    - scaling_schedules: Autoscaling scaling schedule block.
    - stateful_disks: List of stateful disks created on the instances that will be preserved on instance delete.
    - stateful_ips: List of stateful IPs created on the instances that will be preserved on instance delete.
    - target_pools: The target load balancing pools to assign this group to.
    - target_size: The target size for the managed instance group.
    - update_policy: The rolling update policy.
    - wait_for_instances: Whether to wait for all instances to be created/updated before returning.
  EOD

  type = object({
    autoscaling_cpu     = optional(list(map(string)), [])
    autoscaling_enabled = optional(bool, false)
    autoscaling_lb      = optional(list(map(string)), [])
    autoscaling_metric  = optional(list(map(string)), [])
    autoscaling_mode    = optional(string, "ON")
    autoscaling_scale_in_control = optional(object({
      fixed_replicas   = number
      percent_replicas = number
      time_window_sec  = number
      }), {
      fixed_replicas   = null
      percent_replicas = null
      time_window_sec  = null
    })
    cooldown_period                  = optional(number, 60)
    distribution_policy_target_shape = optional(string, "EVEN")
    distribution_policy_zones        = optional(list(string), [])
    health_check = optional(object({
      type                = string
      initial_delay_sec   = number
      check_interval_sec  = number
      healthy_threshold   = number
      timeout_sec         = number
      unhealthy_threshold = number
      response            = string
      proxy_header        = string
      port                = number
      request             = string
      request_path        = string
      host                = string
      enable_logging      = bool
      }), {
      "check_interval_sec" : 30,
      "enable_logging" : false,
      "healthy_threshold" : 1,
      "host" : "",
      "initial_delay_sec" : 30,
      "port" : 80,
      "proxy_header" : "NONE",
      "request" : "",
      "request_path" : "/",
      "response" : "",
      "timeout_sec" : 10,
      "type" : "",
      "unhealthy_threshold" : 5
    })
    max_replicas = optional(number, 10)
    min_replicas = optional(number, 1)
    scaling_schedules = optional(list(object({
      disabled              = bool
      duration_sec          = number
      min_required_replicas = number
      name                  = string
      schedule              = string
      time_zone             = string
    })), [])
    stateful_disks = optional(list(object({
      device_name = string
      delete_rule = string
    })), [])
    stateful_ips = optional(list(object({
      interface_name = string
      delete_rule    = string
      is_external    = bool
    })), [])
    target_pools = optional(list(string), [])
    target_size  = optional(number, 1)
    update_policy = optional(list(object({
      type                           = string
      instance_redistribution_type   = string
      minimal_action                 = string
      most_disruptive_allowed_action = string
      max_surge_percent              = number
      max_surge_fixed                = number
      max_unavailable_percent        = number
      max_unavailable_fixed          = number
      min_ready_sec                  = number
      replacement_method             = string
    })), [])
    wait_for_instances = optional(bool, false)
  })
}


##################################
### END MANAGED INSTANCE GROUP ###
##################################

#####################
### LOAD BALANCER ###
#####################

variable "load_balancer" {
  description = <<-EOD
    Configuration for the load balancer includes:
    - address: Existing IPv4 address to use (the actual IP address value).
    - certificate: Content of the SSL certificate. Requires SSL to be true and create_ssl_certificate to be true.
    - certificate_map: Certificate Map ID in format projects/{project}/locations/global/certificateMaps/{name}.
    - create_address: Create a new global IPv4 address.
    - create_http_forward: Whether to create an HTTP forward rule for the load balancer.
    - create_ipv6_address: Allocate a new IPv6 address. Conflicts with 'ipv6_address'.
    - create_ssl_certificate: If true, create certificate using private_key/certificate.
    - create_url_map: Set to false if url_map variable is provided.
    - enable_ipv6: Enable IPv6 address on the CDN load-balancer.
    - firewall_networks: Names of the networks to create firewall rules in.
    - firewall_projects: Names of the projects to create firewall rules in.
    - http_forward_port: The port for the HTTP forward rule.
    - https_port: The HTTPS port for the load balancer.
    - https_redirect: Enable HTTPS redirect for the load balancer.
    - ipv6_address: An existing IPv6 address to use (the actual IP address value).
    - load_balancing_scheme: Load balancing scheme type (EXTERNAL, EXTERNAL_MANAGED, INTERNAL_SELF_MANAGED).
    - managed_ssl_certificate_domains: List of domains for managed SSL certificates.
    - private_key: Content of the private SSL key.
    - random_certificate_suffix: Bool to enable/disable random certificate name generation.
    - server_tls_policy: The resource URL for the server TLS policy to associate with the https proxy service.
    - ssl: Enable SSL for the load balancer.
    - ssl_certificates: SSL cert self_link list.
    - ssl_policy: Selfink to SSL Policy.
    - target_service_accounts: List of target service accounts for health check firewall rule.
    - target_tags: List of target tags for health check firewall rule.
    - url_map: The url_map resource to use. Default is to send all traffic to first backend.
  EOD

  type = object({
    address                         = optional(string, null)
    certificate                     = optional(string, null)
    certificate_map                 = optional(string, null)
    create_address                  = optional(bool, true)
    create_http_forward             = optional(bool, true)
    create_ipv6_address             = optional(bool, false)
    create_ssl_certificate          = optional(bool, false)
    create_url_map                  = optional(bool, true)
    enable_ipv6                     = optional(bool, false)
    firewall_networks               = optional(list(string), ["default"])
    firewall_projects               = optional(list(string), ["default"])
    http_forward_port               = optional(number, 80)
    https_port                      = optional(number, 443)
    https_redirect                  = optional(bool, false)
    ipv6_address                    = optional(string, null)
    load_balancing_scheme           = optional(string, "EXTERNAL_MANAGED")
    managed_ssl_certificate_domains = optional(list(string), [])
    private_key                     = optional(string, null)
    random_certificate_suffix       = optional(bool, false)
    server_tls_policy               = optional(string, null)
    ssl                             = optional(bool, false)
    #ssl_certificates                 = optional(list(string), [])
    ssl_policy              = optional(string, null)
    target_service_accounts = optional(list(string), [])
    target_tags             = optional(list(string), [])
    url_map                 = optional(string, null)
  })
}

#########################
### END LOAD BALANCER ###
#########################

#############################
### LOAD BALANCER BACKEND ###
#############################

variable "load_balancer_backend" {
  description = <<-EOD
    Configuration for the load balancer backend includes:
    - affinity_cookie_ttl_sec: Lifetime of cookies in seconds if session_affinity is GENERATED_COOKIE.
    - backend_port: Port of backend service for load balancer.
    - backend_port_name: Name of port of backend service for load balancer.
    - backend_protocol: The protocol this BackendService uses to communicate with backends.
    - cdn_policy: CDN config for load balancer.
    - compression_mode: Compress text responses using Brotli or gzip compression.
    - custom_request_headers: Headers that the HTTP/S load balancer should add to proxied requests.
    - custom_response_headers: Headers that the HTTP/S load balancer should add to proxied responses.
    - enable_cdn: Enable CDN for load balancer backend.
    - http_health_check: HTTP health check configuration.
    - iap_config: IAP config for load balancer.
    - log_config: Log config for load balancer.
    - security_policy: The security policy associated with this backend service.
    - session_affinity: Type of session affinity to use.
    - timeout_sec: How many seconds to wait for the backend before considering it a failed request.
  EOD

  type = object({
    affinity_cookie_ttl_sec = optional(number, null)
    backend_port            = optional(number)
    backend_port_name       = optional(string)
    backend_protocol        = optional(string, "HTTP")
    cdn_policy = object({
      cache_mode                   = optional(string)
      signed_url_cache_max_age_sec = optional(string)
      default_ttl                  = optional(number)
      max_ttl                      = optional(number)
      client_ttl                   = optional(number)
      negative_caching             = optional(bool)
      negative_caching_policy = optional(object({
        code = optional(number)
        ttl  = optional(number)
      }))
      serve_while_stale = optional(number)
      cache_key_policy = optional(object({
        include_host           = optional(bool)
        include_protocol       = optional(bool)
        include_query_string   = optional(bool)
        query_string_blacklist = optional(list(string))
        query_string_whitelist = optional(list(string))
        include_http_headers   = optional(list(string))
        include_named_cookies  = optional(list(string))
      }))
      bypass_cache_on_request_headers = optional(list(string))
    })
    compression_mode        = optional(string, "")
    custom_request_headers  = optional(list(string), [])
    custom_response_headers = optional(list(string), [])
    http_health_check = optional(object({
      check_interval_sec  = optional(number)
      healthy_threshold   = optional(number)
      timeout_sec         = optional(number)
      unhealthy_threshold = optional(number)
      port                = optional(number)
      request_path        = optional(string)
      logging             = optional(bool)
      protocol            = optional(string)
      port_specification  = optional(string)
      proxy_header        = optional(string)
      port_name           = optional(string)
      request             = optional(string)
      response            = optional(string)
      host                = optional(string)
      }), {
      check_interval_sec  = 30
      healthy_threshold   = 1
      timeout_sec         = 5
      unhealthy_threshold = 5
      port                = 80
      request_path        = "/"
      logging             = false
    })
    iap_config = optional(object({
      enable               = bool
      oauth2_client_id     = optional(string)
      oauth2_client_secret = optional(string)
    }), { enable = false })
    log_config = optional(object({
      enable      = optional(bool)
      sample_rate = optional(number)
    }), { enable = false })
    security_policy  = optional(string, "")
    session_affinity = optional(string, "NONE")
    timeout_sec      = optional(number, 30)
  })
}

#################################
### END LOAD BALANCER BACKEND ###
#################################