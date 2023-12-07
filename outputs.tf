output "ssh_login" {
  description = "SSH login command."
  value       = "ssh -i proxysshkey.pem ubuntu@${aws_eip.eip_proxy.public_ip}"
}

output "mitm_start_manually" {
    description = "Command to start mitmdump (as root)"
    value       = "mitmdump --set block_global=false --proxyauth ${var.proxy_user}:${var.proxy_pass}"
}

output "curl_check" {
    description = "Curl command to check proxy."
    value       = "curl -kL --proxy http://${var.proxy_user}:${var.proxy_pass}@${aws_eip.eip_proxy.public_ip}:${var.proxy_port} https://google.com"
}

output "curl_get_mitm_proxy_cert" {
    description = "Curl command to get the mitm proxy cert."
    value       = "curl -kL --proxy http://${var.proxy_user}:${var.proxy_pass}@${aws_eip.eip_proxy.public_ip}:${var.proxy_port} -o proxy_cert.pem http://mitm.it/cert/pem"
}