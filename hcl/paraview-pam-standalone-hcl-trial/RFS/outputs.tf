
output "info" {
  value = "Welcome to Paraview PAM standalone Trial edition. Please wait about 5mins then you should able to access http://${module.eip.ip[0]} with _sysadmin and Admin.123 credential."
}