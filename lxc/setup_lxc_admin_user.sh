#!/bin/bash

# Usage: ./setup_lxc_admin_user.sh <CTID> <USERNAME>

CTID=$1
USERNAME=$2
GROUP="sudo"             # Use 'wheel' for CentOS/RHEL
PASSWORD="ChangeMe123"   # Temporary password

if [[ -z "$CTID" || -z "$USERNAME" ]]; then
  echo "Usage: $0 <CTID> <USERNAME>"
  exit 1
fi

# Check if container exists
if ! pct status "$CTID" &>/dev/null; then
  echo "Error: LXC container $CTID does not exist."
  exit 1
fi

# Run commands inside the container
pct exec "$CTID" -- bash -c "
  # Install sudo and OpenSSH if needed
  apt-get update && apt-get install -y sudo openssh-server

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
"

echo "✅ Admin user '$USERNAME' created in CT $CTID with SSH 
access and forced password change."
