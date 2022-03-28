output "crdb_console" {
  value = "http://${module.common.lb_ip}:8080"
}