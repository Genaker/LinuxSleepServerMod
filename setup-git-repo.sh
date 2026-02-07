#!/bin/bash
# Setup and push to GitHub repository

set -e

REPO_URL="git@github.com:Genaker/LinuxSleepServerMod.git"

echo "Setting up git repository in LockScreen directory..."

# Change to LockScreen directory
cd "$(dirname "$0")"

# Initialize git if not already initialized
if [ ! -d .git ]; then
    git init
    echo "Git repository initialized"
fi

# Add remote if not exists
if ! git remote get-url origin > /dev/null 2>&1; then
    git remote add origin "$REPO_URL"
    echo "Remote added: $REPO_URL"
else
    git remote set-url origin "$REPO_URL"
    echo "Remote updated: $REPO_URL"
fi

# Add all files
git add README.md BUILD.md Makefile go.mod \
    lid-lock-daemon.sh lid-lock-stop-gnome.sh setup-lid-gui-sudo.sh \
    lid-lock-daemon.go lid-lock-stop-gnome.go \
    lid-lock.desktop lid-lock-go.desktop \
    .gitignore

# Commit
git commit -m "Initial commit: Linux Sleep Server Mod - Lock screen without suspending" || echo "Nothing to commit or already committed"

# Push to main branch
echo "Pushing to GitHub..."
git branch -M main
git push -u origin main

echo "Done! Repository pushed to GitHub."
