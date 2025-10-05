
> **New in this build:** GUI toggle for **Advanced Diagnostics Logging** (optional). Basic logs stay simple; advanced logs add PID/Thread, CPU/RAM %, disk I/O samples, step timing, and exceptions. A **Personal README** is auto-generated on Desktop after install.

# 🤠 Heath’s Ultimate One-Host AI Stack Installer
**Repo:** [KFZZINGER101/Heath-s-Ultimate-One-Host-AI-Stack-Installer](https://github.com/KFZZINGER101/Heath-s-Ultimate-One-Host-AI-Stack-Installer.git)

🔥 **The most powerful free offline + online uncensored AI stack of 2025**

A single PowerShell script that automatically installs, configures, and links together every major open-source AI tool — large-language models, image generation, interpreters, and developer utilities — into **one unified local hub** at  
👉 **[http://localhost:3000](http://localhost:3000)**  

No API keys • No subscriptions • No censorship • 100 % transparent  


---

## 🧭 What This Script Does
---

## 🪟 GUI Edition (New for 2025)

**Heath's AI Installer GUI** adds a full Windows Forms interface with:
- Automatic admin elevation prompt (asks to relaunch as Administrator).
- Full Install vs Custom Install mode.
- Category checkboxes for Core Tools, AI Tools, Models, Enhancements, and ComfyUI Extras.
- Scrollable sub-options for individual AI components (Ollama, ComfyUI, A1111, Open WebUI).
- Progress bar and live status display.
- Saves custom selections to a JSON config for reuse in command-line installs.

**GUI Features:**
| Feature | Description |
|----------|--------------|
| 🧩 **Run Full Install** | Installs everything automatically without prompts. |
| ⚙️ **Run Custom Install** | Lets you pick individual components before continuing. |
| 🧱 **Admin Auto-Elevation** | Relaunches itself as Administrator if not already. |
| 🪄 **Progress Tracking** | Visual progress bar and real-time status labels. |
| 🧾 **Persistent Choices** | Stores custom install selections for next launch. |

---

## 🧩 Deep System Diagnostics

The installer performs **hardware benchmarking** before setup:

| Test | Description |
|------|--------------|
| 💾 Disk I/O Test | Writes and reads 100 MB to measure disk speed (warns if <100MB/s). |
| 🌐 Network Test | Runs `speedtest-cli` to check internet download speed. |
| 🧠 RAM & Disk Space Check | Logs total memory and warns if <16GB RAM or <60GB free space. |
| 🧮 CPU Benchmark | Multi-threaded matrix math test using PyTorch. |
| 🧩 GPU Benchmark | Detects NVIDIA, AMD, or Intel GPUs and runs PyTorch GPU vs CPU comparison. |

The results determine which backend (CUDA / ROCm / Intel / CPU) gets installed automatically.

---

## 🎨 Model Management (SDXL Integrity Check)

SDXL Base 1.0 is automatically downloaded, verified, and shared between ComfyUI and A1111.

**Integrity Check System:**
- Verifies SHA256 hash before and after download.
- Redownloads automatically if the file is incomplete or corrupted.
- Logs model status and links it to A1111’s model folder automatically.

---

## 🧠 Auto-Tuning & Launch Scripts

The installer creates optimized launchers for each tool:

| Tool | Auto-Tune Features |
|------|---------------------|
| 🧠 **A1111** | Creates `webui-user.bat` with flags based on VRAM (lowvram, medvram, or CUDA). |
| 🧩 **ComfyUI** | Creates `start_comfyui.bat` with tuned PyTorch memory allocation. |
| ⚙️ **Torch** | Installs the matching build (CUDA, ROCm, Intel, or CPU). |

---

## 🧩 ComfyUI Enhancements

Adds ready-to-use workflows and nodes:
- Downloads **SDXL_base_only.json** and **SDXL_advanced.json** automatically.
- Installs **ComfyUI-Custom-Scripts** repository if missing.
- Suggests workflow configuration in the log file.

---

## 🌍 Open WebUI (Main Hub)

The installer automatically:
- Starts Docker Desktop and waits until Docker is ready.
- Runs the **Open WebUI container** with GPU or CPU image automatically.
- Configures **auto-restart** (`--restart unless-stopped`).
- Writes **`config.json`** with connected tools (Ollama, ComfyUI, A1111).
- Detects local models and sets the best default automatically.
- Tunes performance mode (CPU / GPU).

---

## 🔁 Autostart, Recovery & Task Scheduler

The installer creates:
- 🖇️ Desktop shortcut → **Start My AI.lnk**
- 🔁 Restart script → **Restart_AI_Services.bat**
- 🧱 Task Scheduler job → **HeathAIStack** (runs on login)
- ♻️ Retry system → If Docker isn’t ready, retries every 10 seconds up to 9 times.
- 🧩 Recovery policy → Repeats startup every 5 minutes if a failure occurs.

---

## 🧩 Full Logging & Guides

Every step is written to:
- **AI_Installer_Log.txt** (on Desktop) — logs categories `[SYSTEM] [GPU] [MODEL] [AI] [AUTOSTART]` etc.
- Auto-opens in Notepad at the end with a Quick Start guide and ASCII map of your AI stack.

---

## 📊 Summary of All Added Features

✅ GUI-based install with Full & Custom modes  
✅ Auto-admin relaunch  
✅ Hardware detection & benchmarking (RAM, disk, CPU, GPU, network)  
✅ Disk I/O and Speedtest integration  
✅ SHA256-verified SDXL download + A1111 mirror  
✅ Torch auto-select for CUDA/ROCm/Intel/CPU  
✅ VRAM-aware auto-tuning for A1111 & ComfyUI  
✅ Docker recovery & restart policy  
✅ Open WebUI auto-configuration  
✅ Task Scheduler with 5-minute retry recovery  
✅ ComfyUI presets and custom node installer  
✅ Persistent logs and Quick Start guide launch  

---

 – Step by Step
| Stage | Description |
|:--|:--|
| **1️⃣ Logging System** | Creates `AI_Installer_Log.txt` on Desktop with timestamps and categories (`SYSTEM`, `INSTALL`, `GPU`, etc.). |
| **2️⃣ Admin Check** | Ensures PowerShell is run as Administrator. |
| **3️⃣ System Checks** | Detects RAM, free disk, and tests disk I/O speed. |
| **4️⃣ Network Test** | Runs `speedtest-cli`; logs download speed. |
| **5️⃣ Dependency Install** | Installs Git, Docker Desktop (WSL2), Python 3.12, Ollama, VC++ Runtime, VS Code via Winget. |
| **6️⃣ VS Code Extensions** | Auto-installs AI and dev extensions. |
| **7️⃣ Clone Repos** | Downloads ComfyUI and Automatic1111 (A1111). |
| **8️⃣ Python & Torch** | Creates venv and installs the right PyTorch build (CUDA / ROCm / Intel / CPU). |
| **9️⃣ GPU Benchmark** | Detects GPU type + runs matrix tests vs CPU. |
| **🔟 CPU Benchmark** | Runs multi-threaded torch matrix test. |
| **11️⃣ Recommendations** | Summarises RAM/disk/network suggestions. |
| **12️⃣ SDXL Model** | Downloads Stable Diffusion XL (~6 GB). |
| **13️⃣ Model Linking** | Shares same checkpoint with A1111 & ComfyUI. |
| **14️⃣ SD Auto-Tune** | Writes optimized launch flags based on VRAM. |
| **15️⃣ A1111 Defaults** | Sets sampler = `DPM++ 2M Karras`, fixes configs. |
| **16️⃣ ComfyUI Presets** | Adds example SDXL workflows + custom scripts. |
| **17️⃣ Open WebUI Setup** | Starts Docker container for the main hub. |
| **18️⃣ Restart Policy** | Sets `unless-stopped` for auto restart. |
| **19️⃣ WebUI Config** | Links Ollama → LLMs, ComfyUI → Images, A1111 → Alt UI, LangChain → Tools. |
| **20️⃣ Ollama Models** | Pulls Llama 3.1 8B, Mistral 7B, Phi-3 Medium, Code Llama 7B, Gemma 7B. |
| **21️⃣ Autostart Scripts** | Creates desktop shortcut + `Restart_AI_Services.bat`. |
| **22️⃣ Task Scheduler** | Runs stack on login. |
| **23️⃣ Recovery** | Retries if Docker isn’t ready. |
| **24️⃣ Quick Guide** | Appends usage tips and opens Notepad. |
| **✅ Finish** | When “Installer finished!” appears, you’re ready. |

---

## ⚙️ Core Installs
Git • Python 3.12 • VC++ Runtime • Docker Desktop (WSL2) • Visual Studio Code • Ollama  

---

## 🤖 AI Stack Included
### 🧩 Open WebUI (Main Hub)
Web interface for chat, agents & tools → [http://localhost:3000](http://localhost:3000)  
*(by Open WebUI Team — BSD-3 license)*  

### 🧠 Language Models (Ollama)
Pre-pulled: `llama3.1:8b`, `mistral:7b`, `phi3:medium`, `codellama:7b`, `gemma:7b`

### 🎨 Image Generation
| Tool | Credits | License |
|:--|:--|:--|
| ComfyUI | Comfyanonymous | GPL-3.0 |
| Automatic1111 | AUTOMATIC1111 Team | AGPL-3.0 |
| Stable Diffusion XL Base 1.0 | Stability AI | CreativeML OpenRAIL-M |

Shared checkpoint → no duplicate downloads.  

### 🧩 Agents & Tools
LangChain • Open-Interpreter • Continue.dev  

---

## ⚡ Adaptive Hardware Handling
Detects GPU type, installs matching Torch build, benchmarks CPU vs GPU, logs RAM/Disk/Network results, auto-selects best backend.  

---

## 🧠 Developer Environment
Installs VS Code + extensions like Continue.dev, GitLens, Prettier, Python, PowerShell, YAML, etc.  
Enables AI pair programming and smooth coding experience.  

---

## 🪄 Auto-Start & Recovery
- Desktop shortcut → **Start My AI.lnk**  
- Restart script → **Restart_AI_Services.bat**  
- Scheduled Task runs stack on login  
- Retries Docker until ready  
- Container auto-restarts on failure  

---

## 🧰 Folder Layout
```
C:\Users\<You>\
 ├─ ComfyUI\
 ├─ stable-diffusion-webui\
 ├─ .ollama\
 ├─ .open-webui\
 └─ Desktop\
      ├─ AI_Installer_Log.txt
      ├─ Start My AI.lnk
      └─ Restart_AI_Services.bat
```

---

## 🧾 Quick Install — Heath's Ultimate One-Host AI Stack
```powershell
cd "$env:USERPROFILE\Desktop"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Force UTF-8 clean download from GitHub
$installerUrl = "https://raw.githubusercontent.com/KFZZINGER101/-Heath-s-Ultimate-One-Host-AI-Stack-Installer-/main/Heath_AI_Installer_GUI.ps1"
$installerFile = "Heath_AI_Installer_GUI.ps1"
Invoke-WebRequest -Uri $installerUrl -OutFile $installerFile -UseBasicParsing
(Get-Content $installerFile -Raw -Encoding UTF8) | Set-Content $installerFile -Encoding UTF8

# Run the installer
powershell.exe -ExecutionPolicy Bypass -File ".\Heath_AI_Installer_GUI.ps1"

# Download and open the README on Desktop
$readmeUrl = "https://raw.githubusercontent.com/KFZZINGER101/-Heath-s-Ultimate-One-Host-AI-Stack-Installer-/main/README.md"
$readmePath = "$env:USERPROFILE\Desktop\Heath_AI_Installer_README.md"
Invoke-WebRequest -Uri $readmeUrl -OutFile $readmePath -UseBasicParsing
Start-Process $readmePath

```

Then sit back and relax — the script does everything.  

After reboot, open your browser to 👉 **http://localhost:3000**

---

## 🧾 Quick-Start Cheat Sheet
| Feature | How to Use |
|:--|:--|
| 💬 Chat | Talk with Ollama models (Llama 3, Mistral, Phi-3 …) |
| 🎨 Images | Use ComfyUI or A1111 inside the hub |
| 🧠 Agents | Enable LangChain & Interpreter in WebUI |
| 💻 Coding | Open VS Code → Continue.dev tab |
| 🔁 Restart Stack | Run `Restart_AI_Services.bat` |
| 🧰 Logs | Check `AI_Installer_Log.txt` on Desktop |

---

## ⚠️ Safety & Transparency
✅ Uses only official sources (Winget + GitHub repos).  
🔍 Every action is logged in `AI_Installer_Log.txt`.  
🧱 No external servers, spyware, or telemetry added.  
🧑‍💻 Anyone can read the PowerShell script to verify.  

---

## 📜 Licensing
**Installer Script:** BSD 3-Clause License © 2025 KFZZINGER101 (Heath Duke)  

You may freely use, modify, and redistribute with credit.  
Do *not* use my name or branding to advertise forks.  

### Third-Party Licenses Summary
| Software | License |
|:--|:--|
| Open WebUI | BSD-3 |
| ComfyUI | GPL-3.0 |
| Automatic1111 | AGPL-3.0 |
| Stable Diffusion XL | CreativeML OpenRAIL-M |
| Ollama | Source-available |
| LangChain / Open-Interpreter / Continue.dev | MIT / Apache |
| Docker Desktop | Apache 2.0 |
| VS Code | MIT |
| Git | GPL-2.0 |
| Python | PSF License |

---

## 🙌 Credits & Acknowledgements
| Category | Contributors |
|:--|:--|
| **Author / Integrator** | **KFZZINGER101 (Heath Duke)** – Creator of the PowerShell installer, auto-tuning system, benchmarking, logging & docs. |
| **AI Hub** | Open WebUI Team |
| **Model Runtime** | Ollama Developers |
| **Image Tools** | Comfyanonymous (ComfyUI) • AUTOMATIC1111 Team |
| **AI Models** | Stability AI • Meta AI • Mistral AI • Microsoft Research • Google DeepMind |
| **Agent Frameworks** | LangChain • Open-Interpreter |
| **Developer Integration** | Continue.dev Team • Microsoft VS Code |
| **Community** | Open-source contributors (2024–2025) who tested and improved the stack |

---

## 🧩 Folder & Service Summary Diagram
```
[ Windows PC ]
      │
      ├── Docker Desktop → Open WebUI (http://localhost:3000)
      │       │
      │       ├── Ollama → Local LLMs (Llama3 / Mistral / Phi3)
      │       ├── ComfyUI → Image Generation (SDXL)
      │       └── A1111 → Alternate Image UI
      │
      ├── VS Code → Continue.dev AI coding
      ├── LangChain / Interpreter → Local agents & tools
      └── Logs + Shortcuts → Desktop (for monitoring)
```

---

## 🎉 Bottom Line
💥 One command installs a complete private AI workstation — ChatGPT-style chat • Stable Diffusion XL • Coding agents • Offline LLMs.  
Runs entirely on your computer, free and uncensored.  

```
🤖💬🎨🛠️  All-in-One.  All Yours.
```

---

## 📂 Repository Extras
### LICENSE (BSD 3-Clause)
```
BSD 3-Clause License
© 2025 KFZZINGER101 (Heath Duke)

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:
1. Redistributions must retain this notice and disclaimer.
2. The name KFZZINGER101 or Heath Duke may not be used to endorse derived products without permission.
3. This software is provided “as is” without warranty of any kind.
```

### .gitignore
```
*.log
*.tmp
__pycache__/
venv/
.env
.cache/
.DS_Store
.ollama/
.open-webui/
ComfyUI/models/
stable-diffusion-webui/models/
```

### .gitattributes
```
* text=auto
*.ps1 text eol=crlf
*.md text eol=lf
```



---

## 🧪 Advanced Technical Reference (Logging)

**Files**
- `AI_Installer_Log.txt` (human-readable)
- `AI_Installer_Log_Advanced.txt` (forensic-level; optional via GUI)
- Archive: `Desktop/AI_Installer_Logs_Archive/` (auto-zips when log > 20 MB)

**Advanced line format**
```
[YYYY-MM-DD HH:MM:SS.mmm ±TZ] PID=12345 TID=7 CPU=17.3% MEM=42.1% DISKFREE=355.8GB :: [INSTALL] ✅ VS Code installed
    DETAIL: winget output / stderr trimmed
```

**What is captured**
- Timestamp with milliseconds, local timezone
- PowerShell PID + ThreadId
- CPU % (total), Memory % used, Disk C: free (GB)
- Category + Emoji status + message
- Optional details: step output, exception text, durations

**When it writes**
- On every `Log()` call across the installer
- Plus step-timers for key phases (dependency install, GPU/CPU tests, model downloads, Docker bring-up)

**Personal README**
- `Desktop/Personal_README.md` auto-generated on finish
- Summarizes system specs, selected options, models and services, log mode, and quick links

*This README was auto-merged on 2025-10-05 09:33:13Z.*
