# aws_mitm_proxy

This repo will setup a MITM proxy server with authentication.
It is a single Ubuntu server in the default vpc.

- Clone this repo: `git clone https://github.com/paulboekschoten/aws_mitm_proxy.git`
- Change directory: `aws_mitm_proxy`
- Copy the tfvars example file: `cp terraform.tfvars_example terraform.tfvars`
- Change values in the terraform.tfvars to your needs
- Run: `terraform init`
- Run: `terraform apply`

Sample output
```
Outputs:

curl_check = "curl -kL --proxy http://paul:paultest123@35.181.189.73:8080 https://google.com"
curl_get_mitm_proxy_cert = "curl -kL --proxy http://paul:paultest123@35.181.189.73:8080 -o proxy_cert.pem http://mitm.it/cert/pem"
mitm_start_manually = "mitmdump --set block_global=false --proxyauth paul:paultest123"
ssh_login = "ssh -o IdentitiesOnly=yes -i proxysshkey.pem ubuntu@35.181.189.73"
```

With `curl_check` you can see if your proxy is working.  
With `curl_get_mitm_proxy_cert` you can download the proxy certificate to trust in your environment.  
With `ssh_login` you can login into your proxy server.  
`mitm_start_manually` is the command that is used by the service to start your proxy server on boot. Use this command to start you proxy manually if needed. (Should be done as root.)  

This proxy server is open to the internet, to accept connections from public ips the option `block_global` is set to false.  
Please use a strong password to protect your proxy.  

MITM proxy options: https://docs.mitmproxy.org/stable/concepts-options/  

To stop/start your MITM proxy please login with ssh and use the following service command(s):  
```
systemctl stop|status|start mitmdump
```

If you want to check the live console output, you can stop the mitmdump service and start manually.  