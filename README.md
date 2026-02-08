# Interstice

**Interstice** is a custom Debian-based Linux distribution designed as a **browser-first operating system**.  
It boots directly into a fullscreen Firefox kiosk that renders a **static HTML interface**, backed by a **local API** capable of executing whitelisted shell commands.

There is **no desktop environment**, **no terminal**, and **no JavaScript framework**.  
The UI *is* the OS.

---

## 🧠 Architecture Overview

Interstice is composed of three runtime layers:

1. **Static Web UI**
   - Plain HTML, CSS, and JavaScript
   - Served locally via a lightweight web server
   - Rendered in Firefox kiosk mode

2. **Local API Daemon**
   - Runs on `localhost`
   - Accepts HTTP requests
   - Executes **whitelisted shell commands only**
   - Acts as the bridge between the UI and the OS

3. **Linux Base System**
   - Debian Live (Bookworm)
   - Autologin
   - No graphical terminal
   - No traditional desktop

---

## 🚀 Features

- Static HTML-based operating system UI
- Firefox ESR in locked kiosk mode
- Local web server (`python3 -m http.server`)
- Local API for system control (Python + Flask)
- Autologin on boot
- No Node.js, no React, no Next.js
- Designed for kiosks, appliances, and embedded systems

---

## 📦 Build Requirements

To build the Interstice ISO, you need a Debian/Ubuntu-based system with:

- `live-build`
- `debootstrap`
- `python3`
- `git`
- `sudo`

Install dependencies:

```bash
sudo apt update
sudo apt install live-build debootstrap git python3 sudo
```

---

## 📁 Repository Layout

```
interstice/
├── interstice.sh        # ISO build script
├── ui/                 # Static HTML UI (served to Firefox)
│   ├── index.html
│   ├── style.css
│   └── app.js
├── api/                # Local system API
│   └── server.py
└── README.md
```

---

## 📥 Adding Your UI

The `ui/` directory contains your operating system interface.

Example:

```
ui/
├── index.html
├── style.css
└── app.js
```

These files will be copied into the ISO at:

```
/opt/interstice/ui
```

They are served at:

```
http://localhost:3000
```

---

## 🔌 Local API (System Control)

Interstice includes a local API daemon that:

- Runs on `http://127.0.0.1:9999`
- Accepts JSON requests
- Executes **only predefined commands**
- Runs as root

### Example API request (from `app.js`):

```js
fetch("http://localhost:9999/run", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ command: "reboot" })
});
```

### Example allowed commands:
- `reboot`
- `shutdown`
- `uptime`
- `hostname`

Commands are **hardcoded and whitelisted** for safety.

---

## 🔨 Building the ISO

Clone the repository and run the build script:

```bash
git clone https://github.com/yourusername/interstice.git
cd interstice
chmod +x interstice.sh
./interstice.sh
```

When the build completes, you will get:

```
live-image-amd64.hybrid.iso
```

This is a bootable ISO.

---

## 💻 Boot Behavior

When Interstice boots:

1. Linux starts
2. User `interstice` logs in automatically
3. systemd starts:
   - the local API daemon
   - the static web server
4. Firefox launches in fullscreen kiosk mode
5. `http://localhost:3000` loads
6. Your HTML UI becomes the operating system

---

## 🖥️ Terminal Access

Interstice **does not include a graphical terminal**.

- No terminal emulator is installed
- No desktop menu exists
- System control is done **only through the API**

Text TTYs technically exist at the kernel level, but the system is designed to operate without user shell access.

---

## 🔐 Security Model

- API is bound to `127.0.0.1`
- Commands are hardcoded (no user-provided shell input)
- No `shell=true`
- No exposed network services
- UI cannot directly execute commands

This design is suitable for kiosks, appliances, and locked-down systems.

---

## 🧭 What Interstice Is (and Is Not)

### Interstice **is**:
- A browser-based operating system
- A kiosk / appliance OS
- A static HTML-powered shell

### Interstice **is not**:
- A desktop Linux distro
- A development environment
- A web app framework

---

## 📜 License

MIT License © 2025 Astron
