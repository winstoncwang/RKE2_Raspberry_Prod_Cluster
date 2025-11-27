#!/bin/bash
# Provisioning and hardening script for bastion host SSH configuration
# Ensure SSH Public Key auth is setup before running hardening

NEW_PORT=${1:-2222}
SSH_USER="provisioner"
# SSH_PUBKEY=<REDATED>

echo "==============================="
echo " SSH Hardening ..."
echo "==============================="
sleep 1

# Check if root user
if [[ $EUID -ne 0 ]]; then
	echo "Error: Please run as root (sudo) user."
	exit 1
fi

# Create user
if ! id "$SSH_USER" >/dev/null 2>&1; then
	echo "[+] Creating user $SSH_USER"
	useradd -m -s /bin/bash "$SSH_USER"
fi
	usermod -aG sudo "$SSH_USER"

USER_HOME=$(getent passwd "$SSH_USER" | cut -d: -f6)
mkdir -p "$USER_HOME/.ssh"
chmod 700 "$USER_HOME/.ssh"
chown "$SSH_USER:$SSH_USER" "$USER_HOME/.ssh"
if ! grep -qxF "$SSH_PUBKEY" "$USER_HOME/.ssh/authorized_keys"; then
	echo "$SSH_PUBKEY" >> "$USER_HOME/.ssh/authorized_keys"
fi
chmod 600 "$USER_HOME/.ssh/authorized_keys"
chown "$SSH_USER:$SSH_USER" "$USER_HOME/.ssh/authorized_keys"

# Enable user provisioner
if ! grep -qE "^AllowUsers .*" /etc/ssh/sshd_config; then
	echo "[+] Add provisioner user for ssh access"
	echo "AllowUsers provisioner" >> /etc/ssh/sshd_config
fi
sed -i "s/^AllowUsers .*/AllowUsers provisioner/" /etc/ssh/sshd_config

# Allow inbound access from IP(PC ip) and drop the rest
echo "[+] Setup iptables user ip and ssh access"
## iptables -I INPUT -s <IP> -p tcp -dport 80 -j ACCEPT
## iptables -I INPUT -p tcp --dport 2222 -s <IP> -j ACCEPT
iptables -I INPUT -j DROP

# Backup and change port number in config file
echo "[+] Backing up /etc/ssh/sshd_config to /etc/ssh/sshd_config.bak"
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Change SSH default port to new port
echo "[+] Updating SSH default port to new port"
sed -i "s/#Port .*/Port $NEW_PORT/" /etc/ssh/sshd_config
sed -i "s/PorT 22/PorT $NEW_PORT/" /etc/ssh/sshd_config

# Ensure SSH protocal 1 is disabled
echo "[+] Disable SSH Protocal 1"
sed -i "s/Protocol 1/Protocol 2/" /etc/ssh/sshd_config

# Disable Direct Root Login
echo "[+] Disable root login"
sed -i "s/^PermitRootLogin .*/PermitRootLogin no/" /etc/ssh/sshd_config

# Disable Password auth and allow PubKey auth
echo "[+] Disable password auth and enable pubkey auth"
sed -i "s/^PasswordAuthentication .*/PasswordAuthentication no/" /etc/ssh/sshd_config
sed -i "s/^PubkeyAuthentication .*/PubkeyAuthentication yes/" /etc/ssh/sshd_config

# --------Restart ssh---------
sshd -t || { echo "sshd_config syntax error, aborting"; exit 1; }

echo "[+] Restarting SSH service..."
(systemctl restart ssh || systemctl restart sshd)


