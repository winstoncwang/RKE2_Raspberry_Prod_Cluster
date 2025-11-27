#!/bin/bash
# Usage: local_key_gen.sh <port> <username@bastion-ip>

ssh-keygen -t ed25519 -C "local-key"

ssh-copy-id -i ~/.ssh/id_ed25519.pub -p "$1" "$2"
