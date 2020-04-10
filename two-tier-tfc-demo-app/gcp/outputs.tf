output "pool_public_ip" {
  value = google_compute_forwarding_rule.two-tier-tfe-demo-app.ip_address
}

output "instance_ips" {
  value = join(
    " ",
    google_compute_instance.two-tier-tfe-demo-app.*.network_interface.0.access_config.0.nat_ip,
  )
}

