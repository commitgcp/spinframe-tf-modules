# Spinframe Terraform Modules

This repository contains a set of modules used to set up a project for Spinframe. The six modules whose names start with "spinframe" depend on the module called "mig-with-https-lb", which creates a managed instance group and an HTTP(s) load balancer.

## SSL

The module creates an SSL certificate for you, for domains that you provide in the variable "domains". This variable is required in all of the modules. If you would like to use a sslip.io domain (ex. <IP-ADDRESS>.sslip.io), first create an external global static IP address in GCP, then set the variable load_balancer.address to a string containing the IP address, and add "<IP-ADDRESS>.sslip.io" to the "domains" list variable.

## CDN

For the projects in which you need CDN: this is configured in the "load_balancer_backend" object variable. You must set "enable_cdn" to true, and provide a cdn_policy.

## Vision API

In the spinframe-dev-rsports module, the service account which runs the Managed Instance Group has the Vision API Admin role. This role is in Beta, so please beware of any issues and report them to: akiva.ashkenazi@comm-it.cloud