# 📅 Midnight Node Status Push

This repository contains a script that securely pushes node metrics to a Cloudflare Worker endpoint for the [Midnight Pool Status](https://midnight.poolinfo.me/) dashboard.

---

## 🔍 Overview
This tool is meant for Midnight node validators who want to:
- Monitor their node health and performance, and showcase it to delegators.
- Contribute node data to the public community dashboard.

The push script collects real-time information such as block height, sync percentage, uptime, and key checks (Aura, Grandpa, Sidechain). The script does **not** send out public keys — only the key presence status. All data is securely transmitted to a Cloudflare Worker.

---

## ⚡ Requirements
- A running Midnight validator node
- Bash shell (Linux/macOS)
- `curl`, `jq`, and `docker` installed on your system
- An API key (see below to request)

---

## 🔐 Request Your API Key
To push your node data, you need an API key associated with your pool name.

### How to Request:
1. Request via [Midnight Discord](https://discord.gg/tqCMDNuC)
2. Or join [Enigma SPO Discord](https://discord.gg/bHMPsP7U)

Please provide:
- Desired node name (e.g., `MoonStake`, `Enigma`)

Once approved, you will receive:
- A unique **API Key** to be used in the Authorization header

---

## ⚙️ Setup Instructions

1. **Download the script directly:**
   ```bash
   curl -O https://raw.githubusercontent.com/Midnight-Scripts/push-status/main/push_status.sh
   chmod +x push_status.sh
   ```

2. **Set your API key and endpoint:**
   Edit the script `push_status.sh`:
   ```bash
   API_KEY="your-key-here"
   ENDPOINT="https://midnight.voise.workers.dev/push"
   ```

3. **Test your push:**
   ```bash
   ./push_status.sh
   ```
   You should see:
   ```
   ✅ Data stored for YourNodeName
   ```

---

## ⏱ Recommended Cron Setup
To send updates every 30 seconds:

```bash
crontab -e
```
Add the following lines:
```bash
* * * * * /path/to/push_status.sh
* * * * * sleep 30 && /path/to/push_status.sh
```

---

## ⛔ Security Notes
- Your API key is rate-limited: **Max 2 pushes per minute**
- More than 2 pushes per minute → **5-minute temporary block**
- Invalid payload format → **permanent block**
- Unauthorized or unknown keys are rejected

---

## ✨ Want to Display Your Pool?
All submitted data appears live at:
**[Midnight Pool Dashboard](https://midnight.poolinfo.me/)**

---

## 📈 Data Pushed
The following fields are tracked:
- `node_key`
- `midnight_version`
- `started_at`
- `uptime`
- `latest_block`
- `finalized_block`
- `sync`
- `peers`
- `blocks_produced`
- `status`
- `keys.aura`, `keys.grandpa`, `keys.sidechain`

---

## 🚀 Contribute
Feel free to submit PRs or suggest improvements.
If you build tools on top of this — we'd love to hear from you!

---

## 📁 License
MIT

