#!/bin/bash
sfile="https://github.com/daffahelmi/nissa/blob/main"

# Change Repo Id Debian 12
wget -O /root/repoid https://raw.githubusercontent.com/daffahelmi/nissa/main/repositoryid && chmod +x /root/repoid && /root/repoid && rm -f /root/repoid

# Input domain
read -rp "Masukkan Domain: " domain
echo "$domain" > /root/domain
domain=$(cat /root/domain) 

# Install toolkit
apt-get update
timedatectl set-timezone Asia/Jakarta && \
apt-get install net-tools lnav haveged htop vnstat gpg neofetch jq -y

# Preparation
clear
cd;
apt-get upgrade -y;

# Remove unused Modules
apt-get purge -y samba* apache2* sendmail* bind9*

# Install BBR
echo 'fs.file-max = 500000
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 4096
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mem = 25600 51200 102400
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.core.rmem_max=4000000
net.ipv4.tcp_mtu_probing = 1
net.ipv4.ip_forward=1
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1' >> /etc/sysctl.conf
sysctl -p;

# Install Marzban
sudo bash -c "$(curl -sL https://github.com/daffahelmi/Marzban-scripts/raw/master/marzban.sh)" @ install

# Install socat
apt install iptables cron socat -y

# Install SSL cert
sudo mkdir -p /var/lib/marzban/certs/ && \
marzban down && \
curl https://get.acme.sh | sh && \
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --issue --standalone -d $domain \
--key-file /var/lib/marzban/certs/key.pem \
--fullchain-file /var/lib/marzban/certs/fullchain.pem

# cronjob setup
(crontab -l 2>/dev/null; echo "0 */6 * * * sync; echo 3 > /proc/sys/vm/drop_caches"; echo "0 */3 * * * systemctl restart wireproxy") | crontab -

# Swap RAM 1GB
wget https://raw.githubusercontent.com/Cretezy/Swap/master/swap.sh -O swap && sh swap 1G && rm swap

# Download xray_config.json
wget -O /var/lib/marzban/xray_config.json https://raw.githubusercontent.com/daffahelmi/nissa/main/xray_config.json

# Download .env
wget -O /opt/marzban/.env https://raw.githubusercontent.com/daffahelmi/nissa/main/env

# Download Subscription
sudo wget -N -P /var/lib/marzban/templates/subscription/  https://raw.githubusercontent.com/daffahelmi/nissa/main/index.html

# Download Sqlite3
wget -O /var/lib/marzban/db.sqlite3 https://raw.githubusercontent.com/daffahelmi/nissa/main/db.sqlite3

# Install Xray-Core Latest
apt install -y wget unzip && \
mkdir -p /var/lib/marzban/xray-core && \
cd /var/lib/marzban/xray-core && \
wget https://github.com/XTLS/xray-core/releases/latest/download/Xray-linux-64.zip && \
unzip Xray-linux-64.zip && \
rm Xray-linux-64.zip

# Download Geositemod
wget -O /root/geositemod https://raw.githubusercontent.com/daffahelmi/nissa/main/geositemod && chmod +x /root/geositemod && /root/geositemod && rm -f /root/geositemod

# Fix Marzban error log
wget -O /usr/local/bin/fixmarzban https://raw.githubusercontent.com/daffahelmi/nissa/main/fixnodeusage && \
wget -O /etc/systemd/system/fix.service https://raw.githubusercontent.com/daffahelmi/nissa/main/fix.service && \
chmod +x /usr/local/bin/fixmarzban && \
systemctl enable fix.service && \
systemctl start fix.service

# Install cek service
wget -O /root/.bash_profile https://raw.githubusercontent.com/daffahelmi/nissa/main/profile && \
wget -O /usr/bin/cek https://raw.githubusercontent.com/daffahelmi/nissa/main/cek && \
chmod +x /usr/bin/cek

# Optional: Install WARP Proxy
echo -e "\nApakah Anda ingin menginstal WARP Proxy? (y/n) [Timeout 5 detik, default: y]"
read -t 5 -p "Pilih [y/n]: " warp_choice
warp_choice=${warp_choice:-y}

if [[ "$warp_choice" == "y" ]]; then
  bash <(curl -sSL https://raw.githubusercontent.com/hamid-gh98/x-ui-scripts/main/install_warp_proxy.sh) -y
else
  echo "WARP Proxy tidak diinstal."
fi

# Finalizing
apt autoremove -y && apt clean
systemctl restart docker
cd /opt/marzban && docker compose down && docker compose up -d
rm -f /root/marzdaf.sh
