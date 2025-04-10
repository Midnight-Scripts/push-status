# 📅 Midnight Node Status Push

This repository contains a script that  pushes node metrics to a API endpoint for the [Midnight Pool Status](https://midnight.poolinfo.me/) dashboard.

---

<img width="1339" alt="enigma_midnight" src="https://github.com/user-attachments/assets/4fafb924-39fc-4430-a4a6-c79dea276822" />


## 🔍 Overview
This tool is meant for Midnight node validators who want to:
- Monitor their node health and performance, and showcase it to Delegators.
- Contribute node data to the public community dashboard.

The push script collects real-time information such as block height, sync percentage, uptime, and key checks (Aura, Grandpa, Sidechain). The script does **not** send out public or any keys — only the key presence status.

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

Once verified, you will receive:
- A unique **API Key** to be used in the script

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
   ENDPOINT="https://midnightapi-production.up.railway.app/push"
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
To send updates every 15 seconds:

```bash
crontab -e
```
Add the following lines:
note - make sure to update your path plz.
```bash
* * * * * /home/midnight/md_scirpts/push_status.sh
* * * * * sleep 15 && /home/midnight/md_scirpts/push_status.sh
* * * * * sleep 30 && /home/midnight/md_scirpts/push_status.sh
* * * * * sleep 45 && /home/midnight/md_scirpts/push_status.sh
```

---

## ⛔ Security Notes
- Your API key is rate-limited: **Max 10 pushes per minute**
- More than 10 pushes per minute → **5-minute temporary block**
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
