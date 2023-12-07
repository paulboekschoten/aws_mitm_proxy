#cloud-config
packages:
- git 
- jq 
- vim 
- language-pack-en
- wget
- curl
- zip
- unzip
- ca-certificates
- gnupg
- lsb-release
write_files:
  - path: /lib/systemd/system/mitmdump.service
    permissions: '0644'
    content: |  
     [Unit]
     Description=mitmdump service
     After=network.target
     
     [Service]
     Type=simple
     User=root
     ExecStart=/usr/local/bin/mitmdump --set block_global=false --proxyauth ${proxy_user}:${proxy_pass}
     Restart=always
     RestartSec=1
     
     [Install]
     WantedBy=multi-user.target     
  - path: /tmp/install_configure_mitmproxy.sh   
    permissions: '0750'
    content: |
      #!/usr/bin/env bash    

      # install the latest version of mitmproxy 
      curl -o /tmp/${mitm_tar_name} ${mitm_tar_download_url} 
      tar xvzf /tmp/${mitm_tar_name} -C /usr/local/bin/

      # enable the service
      systemctl daemon-reload
      systemctl enable mitmdump.service
      systemctl start mitmdump.service
runcmd:
- bash /tmp/install_configure_mitmproxy.sh