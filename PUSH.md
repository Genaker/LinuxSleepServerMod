# How to Push to GitHub

## Quick Push Instructions

1. **Install git** (if not installed):
```bash
sudo apt install git
```

2. **Configure git** (first time only):
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

3. **Run the setup script**:
```bash
cd /home/ai/LockScreen
./setup-git-repo.sh
```

## Manual Push (Alternative)

If the script doesn't work, do it manually:

```bash
cd /home/ai/LockScreen

# Initialize git
git init

# Add remote
git remote add origin git@github.com:Genaker/LinuxSleepServerMod.git

# Add all files
git add .

# Commit
git commit -m "Initial commit: Linux Sleep Server Mod - Lock screen without suspending"

# Push
git branch -M main
git push -u origin main
```

## Using HTTPS Instead of SSH

If SSH keys aren't set up, use HTTPS:

```bash
git remote set-url origin https://github.com/Genaker/LinuxSleepServerMod.git
git push -u origin main
```

You'll be prompted for your GitHub username and password (or personal access token).
