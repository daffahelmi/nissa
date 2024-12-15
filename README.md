Installer
```bash
apt-get install curl sudo wget -y && wget https://raw.githubusercontent.com/daffahelmi/marzdaf/main/marzdaf.sh && chmod +x marzdaf.sh && ./marzdaf.sh
```
Install with tmux
```bash
apt-get install tmux -y && tmux new-session -d -s marzdaf 'apt-get install curl sudo wget -y && wget https://raw.githubusercontent.com/daffahelmi/marzdaf/main/marzdaf.sh && chmod +x marzdaf.sh && ./marzdaf.sh' && tmux attach-session -t marzdaf
```
Buat admin login
```bash
marzban cli admin create --sudo
```
Backup-marzdaf
```bash
bash <(curl -s https://raw.githubusercontent.com/daffahelmi/marzdaf/main/marzdaf-backup)
```
