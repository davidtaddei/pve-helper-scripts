#!/bin/bash

# Usage: ./setup_pve_admin_user.sh <<USERNAME>

USERNAME=$1
GROUP="sudo"             # Use 'wheel' for CentOS/RHEL
PASSWORD="ChangeMe123"   # Temporary password

if [[ -z "$USERNAME" ]]; then
  echo "Usage: $0 <USERNAME>"
  exit 1
fi

# Install sudo and OpenSSH if needed
apt  update && apt install -y sudo openssh-server

# Ensure SSH service is enabled and started
systemctl enable ssh
systemctl start ssh

# Create user if it doesn't exist
if ! id -u $USERNAME &>/dev/null; then
  useradd -m -s /bin/bash $USERNAME
  echo \"$USERNAME:$PASSWORD\" | chpasswd
  usermod -aG $GROUP $USERNAME
  chage -d 0 $USERNAME
fi

# Add user to pam
pveum useradd $USERNAME@pam
pveum aclmod / -user $USERNAME@pam -role PVEAdmin

echo "✅ Admin user '$USERNAME' created with SSH access and forced password change."
