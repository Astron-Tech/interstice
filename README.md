# Interstice

**Interstice** is a custom Linux distribution built with Debian Live, designed to boot straight into a [Next.js](https://nextjs.org/) + React app running in kiosk mode.  
It ships with Firefox fullscreen, a graphical terminal (`lxterminal`), autologin, and simple scripts to switch between **production** and **development** modes.

---

## 🚀 Features
- **Next.js/React app** served locally at `http://localhost:3000`  
- **Firefox in kiosk mode** as the UI layer  
- **Autologin** to user `interstice`  
- **Systemd service** to run the app  
- **Mode switching scripts**:
  - `set-prod-mode.sh` → runs production (`NODE_ENV=production`)
  - `set-dev-mode.sh` → runs development (`NODE_ENV=development`)
- **Graphical terminal** (`lxterminal`) for easy shell access  

---

## 📦 Requirements

To build Interstice, you’ll need:  
- Debian/Ubuntu-based host system  
- Installed tools:  
  - `live-build`  
  - `debootstrap`  
  - `sudo`  
  - `git`  

Install with:  
```bash
sudo apt update
sudo apt install live-build debootstrap git sudo
```

---

## 🔨 Build ISO

Clone the repo and run the build script:

```bash
git clone https://github.com/yourusername/interstice.git
cd interstice
chmod +x interstice.sh
./interstice.sh
```

When the build finishes, you’ll have an ISO image:  
**`live-image-amd64.hybrid.iso`**

---

## 💻 Running Interstice

- Boot from the ISO (in a VM or on hardware).  
- The system logs in automatically as user **`interstice`**.  
- Firefox launches in **kiosk mode**, pointing to `http://localhost:3000`.  
- The Next.js app runs as a **systemd service**.  

---

## ⚙️ Switching Modes

Inside the running system, use the provided scripts:  

```bash
# Switch to production mode (default)
set-prod-mode.sh

# Switch to development mode
set-dev-mode.sh
```

---

## 🖥️ Accessing the Terminal

Interstice ships with **lxterminal** for graphical shell access.  

- Press **Alt+F2**, type `lxterminal`, press Enter.  
- Or open it from the app menu.  
- You can also switch to a text TTY with **Ctrl+Alt+F2**.  

---

## 📥 Adding Your Next.js App

By default, Interstice looks for your app in:  
`/home/interstice/interstice`

### Step 1 — Make the App Directory
Before running the build script, create this path in your repo:

```bash
mkdir -p config/includes.chroot/home/interstice/interstice
```

### Step 2 — Copy Your Project
Place your Next.js project inside that folder, for example:

```
config/includes.chroot/home/interstice/interstice/package.json
config/includes.chroot/home/interstice/interstice/pages/index.js
```

When the ISO builds, it will appear inside the live system at:

```
/home/interstice/interstice
```

### Step 3 — Dependencies Installed Automatically
During the ISO build, the script runs:

```bash
cd /home/interstice/interstice && npm install
```

so your app’s dependencies are ready on first boot.

### Step 4 — Build for Production
Inside Interstice, run:

```bash
cd ~/interstice
npm run build
```

The systemd service will serve your app at `http://localhost:3000`.

---

## 🛠️ Development Workflow

1. Boot Interstice  
2. Open a terminal (`lxterminal`)  
3. Switch to dev mode:
   ```bash
   set-dev-mode.sh
   ```
4. Run the Next.js dev server:
   ```bash
   cd ~/interstice
   npm run dev
   ```
   Your app now hot-reloads changes.  

When done, switch back with:  
```bash
set-prod-mode.sh
```

---

## 📂 Repo Structure

```
.
├── interstice.sh                   # Build script (creates ISO)
├── config/
│   ├── package-lists/
│   │   └── interstice.list.chroot  # Required packages
│   ├── includes.chroot/
│   │   ├── etc/
│   │   │   ├── lightdm/lightdm.conf
│   │   │   ├── skel/.xinitrc
│   │   │   └── systemd/system/interstice.service
│   │   └── usr/
│   │       ├── share/applications/lxterminal.desktop
│   │       └── local/bin/
│   │           ├── set-prod-mode.sh
│   │           └── set-dev-mode.sh
│   └── includes.chroot/home/interstice/interstice/   # Your Next.js app here
└── README.md
```

---

## 📜 License
MIT License © 2025 Astron
