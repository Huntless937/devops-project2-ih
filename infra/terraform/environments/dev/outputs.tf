output "sonarqube_public_ip" {
  value       = module.compute.sonarqube_public_ip
  description = "Public IP of the SonarQube VM"
}
output "logic_app_trigger_url" {
  value     = module.monitoring.logic_app_trigger_url
  sensitive = true
}
