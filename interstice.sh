#!/bin/bash
set -e

# === Config ===
DISTRO="bookworm" # Debian 12
APP_NAME="interstice"

# === Clean any old build ===
sudo lb clean

# === Configure live-build ===
lb config \
  --distribution "$DISTRO" \
  --debian-installer live \
  --archive-areas "main contrib non-free" \
  --binary-images iso-hybrid

# === Package list ===
mkdir -p config/package-lists
cat > config/package-lists/${APP_NAME}.list.chroot <<'EOF'
lightdm
xserver-xorg
xinit
firefox-esr
network-manager
sudo
git
curl
ca-certificates
nodejs
npm
lxterminal
EOF

# === Autologin setup ===
mkdir -p config/includes.chroot/etc/lightdm
cat > config/includes.chroot/etc/lightdm/lightdm.conf <<'EOF'
[Seat:*]
autologin-user=interstice
autologin-user-timeout=0
user-session=interstice
EOF

# === Create interstice user ===
mkdir -p config/includes.chroot/etc/skel
mkdir -p config/includes.chroot/usr/share/xsessions
cat > config/includes.chroot/usr/share/xsessions/interstice.desktop <<'EOF'
[Desktop Entry]
Name=Interstice
Comment=Interstice Kiosk Session
Exec=startx
Type=Application
EOF

# === X init to launch Firefox kiosk ===
mkdir -p config/includes.chroot/etc/skel
cat > config/includes.chroot/etc/skel/.xinitrc <<'EOF'
#!/bin/bash
# Start Interstice frontend
while true; do
  firefox --kiosk http://localhost:3000
done
EOF
chmod +x config/includes.chroot/etc/skel/.xinitrc

# === Systemd service for Next.js app ===
mkdir -p config/includes.chroot/etc/systemd/system
cat > config/includes.chroot/etc/systemd/system/interstice.service <<'EOF'
[Unit]
Description=Interstice Next.js App
After=network.target

[Service]
WorkingDirectory=/home/interstice/${APP_NAME}
ExecStart=/usr/bin/npm start
Restart=always
User=interstice
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

# === Graphical Terminal desktop entry ===
mkdir -p config/includes.chroot/usr/share/applications
cat > config/includes.chroot/usr/share/applications/lxterminal.desktop <<'EOF'
[Desktop Entry]
Name=Terminal
Comment=Open a terminal window
Exec=lxterminal
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=System;Utility;TerminalEmulator;
EOF

# === Mode switch scripts ===
mkdir -p config/includes.chroot/usr/local/bin
cat > config/includes.chroot/usr/local/bin/set-prod-mode.sh <<'EOF'
#!/bin/bash
sudo sed -i 's/NODE_ENV=.*/NODE_ENV=production/' /etc/systemd/system/interstice.service
sudo systemctl daemon-reexec
sudo systemctl restart interstice
echo "Switched Interstice to PRODUCTION mode."
EOF
chmod +x config/includes.chroot/usr/local/bin/set-prod-mode.sh

cat > config/includes.chroot/usr/local/bin/set-dev-mode.sh <<'EOF'
#!/bin/bash
sudo sed -i 's/NODE_ENV=.*/NODE_ENV=development/' /etc/systemd/system/interstice.service
sudo systemctl daemon-reexec
sudo systemctl restart interstice
echo "Switched Interstice to DEVELOPMENT mode."
EOF
chmod +x config/includes.chroot/usr/local/bin/set-dev-mode.sh

# === Build ISO ===
sudo lb build
