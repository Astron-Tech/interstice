#!/bin/bash
set -e

DISTRO=bookworm
ISO_NAME=interstice
USER=interstice

echo "[*] Installing build dependencies"
sudo apt update
sudo apt install -y \
  live-build \
  debootstrap \
  squashfs-tools \
  xorriso \
  isolinux \
  syslinux \
  python3

echo "[*] Cleaning old build"
sudo lb clean || true
rm -rf config

echo "[*] Configuring live-build"
lb config \
  --distribution $DISTRO \
  --binary-images iso-hybrid \
  --archive-areas "main contrib non-free non-free-firmware" \
  --bootappend-live "boot=live components username=$USER"

echo "[*] Creating directory structure"
mkdir -p config/includes.chroot/opt/interstice/ui
mkdir -p config/includes.chroot/opt/interstice/api
mkdir -p config/includes.chroot/etc/systemd/system
mkdir -p config/includes.chroot/etc/lightdm
mkdir -p config/includes.chroot/home/$USER

echo "[*] Copying UI files"
cp -r ui/* config/includes.chroot/opt/interstice/ui/

echo "[*] Copying API server"
cp api/server.py config/includes.chroot/opt/interstice/api/server.py

echo "[*] Creating systemd service: Interstice API"
cat > config/includes.chroot/etc/systemd/system/interstice-api.service <<EOF
[Unit]
Description=Interstice Local API
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/interstice/api/server.py
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "[*] Creating systemd service: Interstice UI Server"
cat > config/includes.chroot/etc/systemd/system/interstice-ui.service <<EOF
[Unit]
Description=Interstice UI Server
After=network.target

[Service]
ExecStart=/usr/bin/python3 -m http.server 3000
WorkingDirectory=/opt/interstice/ui
Restart=always
User=$USER

[Install]
WantedBy=multi-user.target
EOF

echo "[*] Enabling systemd services"
mkdir -p config/includes.chroot/etc/systemd/system/multi-user.target.wants
ln -s /etc/systemd/system/interstice-api.service \
  config/includes.chroot/etc/systemd/system/multi-user.target.wants/interstice-api.service
ln -s /etc/systemd/system/interstice-ui.service \
  config/includes.chroot/etc/systemd/system/multi-user.target.wants/interstice-ui.service

echo "[*] Configuring LightDM autologin"
cat > config/includes.chroot/etc/lightdm/lightdm.conf <<EOF
[Seat:*]
autologin-user=$USER
autologin-session=openbox
EOF

echo "[*] Creating kiosk startup (.xinitrc)"
cat > config/includes.chroot/home/$USER/.xinitrc <<EOF
#!/bin/sh
exec firefox --kiosk --no-remote --private-window http://localhost:3000
EOF
chmod +x config/includes.chroot/home/$USER/.xinitrc

echo "[*] Defining package list (NO TERMINAL)"
mkdir -p config/package-lists
cat > config/package-lists/interstice.list.chroot <<EOF
xorg
openbox
lightdm
firefox-esr
python3
python3-flask
EOF

echo "[*] Building ISO"
sudo lb build

echo "[✓] Interstice ISO build complete"
