
output "info" {
  value = "Welcome to Paraview Application Server Gateway. Please wait about 5mins then you should able to access http://${module.eip.ip[0]} with [sysadmin/Demo.123!] credential."
}