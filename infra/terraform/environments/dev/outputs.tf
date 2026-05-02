output "sonarqube_public_ip" {
  value       = module.compute.sonarqube_public_ip
  description = "Public IP of the SonarQube VM"
}
