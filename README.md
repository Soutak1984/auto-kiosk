# 🖥 RPi-Kiosk Pro  
Secure, Auto-Recovering, HTTPS-Enabled Raspberry Pi Kiosk System

Designed for Raspberry Pi 4  
Running Raspberry Pi OS 64-bit (Desktop Version)

---

# 🚀 Features

## 🔒 Security
- Local password-protected admin panel
- HTTPS enabled (self-signed certificate)
- Admin password changeable from web UI
- Ctrl+Alt+F1 console disabled
- Alt+Tab disabled
- Right-click disabled
- Raspberry logo hidden
- Boot text hidden

## 🌐 Kiosk Mode
- Fullscreen Chromium
- Mouse cursor hidden
- Network wait before browser launch
- Auto-restart if Chromium crashes
- Custom startup splash screen (banner.jpeg)
- Desktop wallpaper auto-set to banner.jpeg
- Power loss auto recovery enabled

## 🧠 Remote Control (Local Network Only)
- Change displayed webpage from admin panel
- Restart kiosk from admin panel
- Update system remotely
- Change admin password remotely

## 🔄 Stability
- Systemd auto restart
- Watchdog tuning
- Crash recovery
- Auto network wait

---

# 📦 System Requirements

- Raspberry Pi 4 (2GB+ recommended)
- Fresh install of Raspberry Pi OS 64-bit Desktop
- Internet connection for first setup

IMPORTANT: Do NOT use Raspberry Pi OS Lite.

---

# 🛠 Installation

## 1️⃣ Flash Raspberry Pi OS

Install Raspberry Pi OS 64-bit (Desktop version).

Flash using Raspberry Pi Imager.

---

## 2️⃣ Boot & Connect to WiFi

Boot your Pi and open Terminal.

---

## 3️⃣ Install from GitHub

### Option A – One Line Install (Recommended)

Replace YOUR_USERNAME and YOUR_REPO:

curl -sSL https://raw.githubusercontent.com/Soutak1984/auto-kiosk/blob/main/kiosk-local-https.sh | bash

---

### Option B – Download & Inspect

wget https://raw.githubusercontent.com/Soutak1984/auto-kiosk/blob/main/kiosk-local-https.sh  
chmod +x kiosk-local-https.sh  
./kiosk-local-https.sh  

---

## 4️⃣ Reboot

If it does not reboot automatically:

sudo reboot

---

# 🌐 Accessing the Admin Panel

After reboot, from any device on the same network:

https://rpi-kiosk

If hostname does not resolve:

hostname -I

Then open:

https://<RPI_IP>

First time you will see HTTPS warning (self-signed certificate).
Click Advanced → Proceed.

---

# 🔐 Default Login

Username: admin  
Password: admin123  

IMPORTANT: Change password immediately after first login.

---

# 🧑‍💻 Using the Admin Panel

## Change Displayed Website
Enter a new URL and click Save.

Example:
https://example.com

Chromium reloads automatically.

---

## Change Password
Go to:
Settings → Change Password

Enter new password and save.

---

## Restart Kiosk
Click:
Restart Kiosk

---

## Update System
Click:
Update System

Runs:
apt update && apt upgrade

---

# 🖼 Customizing Startup Banner

Replace the file:

/home/pi/banner.jpeg

Recommended resolution:
1920x1080

After replacing:

sudo reboot

This image is used for:
- Boot splash
- Desktop wallpaper
- Loading screen

---

# ⚙ Advanced Configuration

## Change Hostname

sudo raspi-config

System Options → Hostname

---

## Enable Auto Login

sudo raspi-config

System Options → Boot → Desktop Autologin

---

## Change Default Webpage Manually

Edit:

sudo nano /var/www/html/config.json

Example:

{
  "url": "https://yourwebsite.com"
}

Restart kiosk:

sudo systemctl restart kiosk

---

# 🔌 Power Loss Auto Recovery

Already enabled by default.

Verify:

sudo raspi-config  
Advanced Options → Boot Order → SD Card  

---

# 🛡 Security Notes

- Admin panel accessible only from local network
- HTTPS uses self-signed certificate
- Not exposed to internet
- No cloud dependency

If exposing to internet:
- Use firewall
- Use reverse proxy
- Use strong password

---

# 🔄 Updating the Kiosk Script

cd ~  
wget https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/kiosk-local-https.sh -O update.sh  
chmod +x update.sh  
./update.sh  

---

# 🧹 Uninstall

sudo systemctl disable kiosk  
sudo rm /etc/systemd/system/kiosk.service  
sudo reboot  

---

# 🧩 Folder Structure

/var/www/html/        → Admin panel  
/home/pi/banner.jpeg  → Splash image  
/etc/nginx/           → HTTPS config  
/etc/systemd/system/  → Kiosk service  

---

# 🧪 Tested On

- Raspberry Pi 4 (2GB / 4GB / 8GB)
- Raspberry Pi OS 64-bit Desktop
- Chromium latest stable

---

# 📜 License

MIT License

---

# 👨‍💻 Author

Your Name  
GitHub: https://github.com/YOUR_USERNAME
