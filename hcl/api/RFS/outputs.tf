
output "info" {
  value = "Welcome to Paraview API Platform. Please wait about 5mins then you should able to access http://${module.eip.ip[0]} with [admin/Admin!123\&paraview] credential."
}