output "random_password_value" {
  value     = random_password.password.result
  sensitive = true
}
