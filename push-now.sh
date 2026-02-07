#!/bin/bash
# Push script - run this after adding SSH key to GitHub

echo "SSH Public Key (add this to GitHub):"
echo "======================================"
cat ~/.ssh/id_ed25519.pub
echo "======================================"
echo ""
echo "To add this key to GitHub:"
echo "1. Go to: https://github.com/settings/keys"
echo "2. Click 'New SSH key'"
echo "3. Paste the key above and save"
echo ""
read -p "Press Enter after adding the key to GitHub, or Ctrl+C to cancel..."

echo "Testing SSH connection..."
ssh -T git@github.com 2>&1

echo ""
echo "Pushing to GitHub..."
cd "$(dirname "$0")"
git push -u origin main

echo ""
echo "Done! Check https://github.com/Genaker/LinuxSleepServerMod"
