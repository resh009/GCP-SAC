/*
/---------------------------------------\
| Terraform github actions demo         |
|---------------------------------------|
| Author: Mike Winslow                  |
| E-mail: michael.winslow@broadcom.com  |
\---------------------------------------/
*/
//Output

output "nginx-demo-url" {
  value = luminate_web_application.nginx.external_address
}