
# ===================== GUI WRAPPER: Heath's AI Installer (WinForms) =====================
# This wrapper adds:
#  - Admin elevation (auto-relaunch as Administrator)
#  - A WinForms GUI with checkboxes for categories
#  - "Run Full Install" (no prompts) and "Run Custom" behavior
#  - When GUI finishes, it continues running the original installer below.

# --- Admin elevation: relaunch as admin if needed ---
function Ensure-Admin {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    if (-not $isAdmin) {
        $msg = "This installer requires Administrator privileges.`nClick Yes to relaunch as Administrator."
        $res = [System.Windows.Forms.MessageBox]::Show($msg, "Admin Required", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
        if ($res -eq [System.Windows.Forms.DialogResult]::Yes) {
            Start-Process -FilePath pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"" + $MyInvocation.MyCommand.Definition + "`"" -Verb RunAs
        }
        exit
    }
}

# --- Load WinForms assembly (fallback) ---
try {
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
    Add-Type -AssemblyName System.Drawing -ErrorAction Stop
} catch {
    # Try to install compatibility module if Add-Type fails (rare)
    Write-Host "WinForms assemblies missing — attempting to continue. If the GUI fails, run in console mode."
}

# --- Simple GUI layout ---
function Show-InstallerGUI {
    param(
        [switch]$DefaultFullSelected
    )
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Heath's AI Workstation Installer - GUI"
    $form.Width = 760
    $form.Height = 560
    $form.StartPosition = "CenterScreen"
    $form.Font = New-Object System.Drawing.Font("Segoe UI",9)

    # Title label
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "Heath's AI Workstation Installer (GUI) - pick categories or run Full Install"
    $lbl.AutoSize = $true
    $lbl.Font = New-Object System.Drawing.Font("Segoe UI",11,[System.Drawing.FontStyle]::Bold)
    $lbl.Top = 10
    $lbl.Left = 12
    $form.Controls.Add($lbl)

    # Checkboxes group box
    $grp = New-Object System.Windows.Forms.GroupBox
    $grp.Text = "Installation Categories"
    $grp.Width = 720
    $grp.Height = 330
    $grp.Top = 50
    $grp.Left = 12
    $form.Controls.Add($grp)

    # Define checkboxes (default: checked)
    $cbCore = New-Object System.Windows.Forms.CheckBox; $cbCore.Text="Core System Tools (Git, Python, Docker, VS Code)"; $cbCore.AutoSize=$true; $cbCore.Checked = $true; $cbCore.Top=24; $cbCore.Left=12; $grp.Controls.Add($cbCore)
    $cbVSExt = New-Object System.Windows.Forms.CheckBox; $cbVSExt.Text="VS Code Extensions (install selected)"; $cbVSExt.AutoSize=$true; $cbVSExt.Checked = $true; $cbVSExt.Top=56; $cbVSExt.Left=12; $grp.Controls.Add($cbVSExt)
    $cbAITools = New-Object System.Windows.Forms.CheckBox; $cbAITools.Text="AI Tools (Ollama, ComfyUI, A1111, Open WebUI)"; $cbAITools.AutoSize=$true; $cbAITools.Checked = $true; $cbAITools.Top=88; $cbAITools.Left=12; $grp.Controls.Add($cbAITools)
    $cbModels = New-Object System.Windows.Forms.CheckBox; $cbModels.Text="Models (SDXL, LLaMA, Mistral etc.)"; $cbModels.AutoSize=$true; $cbModels.Checked = $true; $cbModels.Top=120; $cbModels.Left=12; $grp.Controls.Add($cbModels)
    $cbEnh = New-Object System.Windows.Forms.CheckBox; $cbEnh.Text="Enhancements (Auto-tune, Shortcuts, Task Scheduler)"; $cbEnh.AutoSize=$true; $cbEnh.Checked = $true; $cbEnh.Top=152; $cbEnh.Left=12; $grp.Controls.Add($cbEnh)
    $cbComfyExtras = New-Object System.Windows.Forms.CheckBox; $cbComfyExtras.Text="ComfyUI presets & custom nodes"; $cbComfyExtras.AutoSize=$true; $cbComfyExtras.Checked = $true; $cbComfyExtras.Top=184; $cbComfyExtras.Left=12; $grp.Controls.Add($cbComfyExtras)

    # Sub-options panel (scrollable)
    $panel = New-Object System.Windows.Forms.Panel
    $panel.Width = 680
    $panel.Height = 100
    $panel.Left = 12
    $panel.Top = 220
    $panel.AutoScroll = $true
    $grp.Controls.Add($panel)

    # Individual AI tools checkboxes inside panel
    $innerTop = 4
    $cbOllama = New-Object System.Windows.Forms.CheckBox; $cbOllama.Text="Ollama"; $cbOllama.AutoSize=$true; $cbOllama.Checked = $true; $cbOllama.Top = $innerTop; $cbOllama.Left = 4; $panel.Controls.Add($cbOllama); $innerTop += 24
    $cbComfy = New-Object System.Windows.Forms.CheckBox; $cbComfy.Text="ComfyUI"; $cbComfy.AutoSize=$true; $cbComfy.Checked = $true; $cbComfy.Top = $innerTop; $cbComfy.Left = 4; $panel.Controls.Add($cbComfy); $innerTop += 24
    $cbA1111 = New-Object System.Windows.Forms.CheckBox; $cbA1111.Text="AUTOMATIC1111 (A1111)"; $cbA1111.AutoSize=$true; $cbA1111.Checked = $true; $cbA1111.Top = $innerTop; $cbA1111.Left = 4; $panel.Controls.Add($cbA1111); $innerTop += 24
    $cbOpenWeb = New-Object System.Windows.Forms.CheckBox; $cbOpenWeb.Text="Open WebUI (Docker image)"; $cbOpenWeb.AutoSize=$true; $cbOpenWeb.Checked = $true; $cbOpenWeb.Top = $innerTop; $cbOpenWeb.Left = 4; $panel.Controls.Add($cbOpenWeb); $innerTop += 24

    # Buttons
    $btnFull = New-Object System.Windows.Forms.Button
    $btnFull.Text = "Run Full Install (no prompts)"
    $btnFull.Width = 240
    $btnFull.Height = 34
    $btnFull.Top = 400
    $btnFull.Left = 20
    $form.Controls.Add($btnFull)

    $btnCustom = New-Object System.Windows.Forms.Button
    $btnCustom.Text = "Run Custom Install (selected boxes)"
    $btnCustom.Width = 260
    $btnCustom.Height = 34
    $btnCustom.Top = 400
    $btnCustom.Left = 280
    $form.Controls.Add($btnCustom)

    $btnExit = New-Object System.Windows.Forms.Button
    $btnExit.Text = "Exit Installer"
    $btnExit.Width = 120
    $btnExit.Height = 34
    $btnExit.Top = 400
    $btnExit.Left = 560
    $form.Controls.Add($btnExit)

    # Progress bar and status
    $progress = New-Object System.Windows.Forms.ProgressBar
    $progress.Width = 720
    $progress.Height = 18
    $progress.Top = 450
    $progress.Left = 12
    $progress.Style = 'Continuous'
    $form.Controls.Add($progress)

    $status = New-Object System.Windows.Forms.Label
    $status.AutoSize = $true
    $status.Top = 478
    $status.Left = 12
    $status.Text = "Status: Idle"
    $form.Controls.Add($status)

    # Event handlers
    $btnExit.Add_Click({
        $form.Close()
        $global:INSTALL_DECISION = "Exit"
    })

    $btnFull.Add_Click({
        # Mark everything to install
        $cbCore.Checked = $true; $cbVSExt.Checked = $true; $cbAITools.Checked = $true; $cbModels.Checked = $true; $cbEnh.Checked = $true; $cbComfyExtras.Checked = $true
        $cbOllama.Checked = $true; $cbComfy.Checked = $true; $cbA1111.Checked = $true; $cbOpenWeb.Checked = $true
        $global:INSTALL_DECISION = "Full"
        $form.Close()
    })

    $btnCustom.Add_Click({
        # Collect selected options into a hashtable for the installer to consume
        $global:INSTALL_DECISION = "Custom"
        $global:INSTALL_OPTIONS = @{
            Core = $cbCore.Checked;
            VSExt = $cbVSExt.Checked;
            AITools = $cbAITools.Checked;
            Models = $cbModels.Checked;
            Enhancements = $cbEnh.Checked;
            ComfyExtras = $cbComfyExtras.Checked;
            Ollama = $cbOllama.Checked;
            ComfyUI = $cbComfy.Checked;
            A1111 = $cbA1111.Checked;
            OpenWebUI = $cbOpenWeb.Checked;
        }
        $form.Close()
    })

    # Show form (modal)
    $form.Add_Shown({$form.Activate()})
    [void]$form.ShowDialog()
}

# If this script is launched directly, ensure admin then show GUI
if ($MyInvocation.InvocationName -eq $MyInvocation.MyCommand.Name) {
    # Attempt to ensure admin (GUI will prompt)
    Ensure-Admin

    # Logging preference first (non-invasive)
    Show-LoggingPrefDialog

    # Show the GUI (default: Full preselected)
    Show-InstallerGUI -DefaultFullSelected

    if ($global:INSTALL_DECISION -eq $null -or $global:INSTALL_DECISION -eq "Exit") {
        Write-Host "Installer cancelled by user."
        exit
    }

    # Export choices as environment variables so the remainder of the script can read them
    if ($global:INSTALL_DECISION -eq "Full") {
        # Write a simple marker file environment to indicate 'Full' install mode
        $env:HEATH_INSTALL_MODE = "Full"
    } elseif ($global:INSTALL_DECISION -eq "Custom") {
        # Serialize selected options into an environment temp file the original script can read
        $json = (ConvertTo-Json $global:INSTALL_OPTIONS -Depth 4)
        $tempOptFile = Join-Path $env:TEMP "heath_install_options.json"
        $json | Out-File -Encoding UTF8 $tempOptFile
        $env:HEATH_INSTALL_MODE = "Custom"
        $env:HEATH_INSTALL_OPTIONS_FILE = $tempOptFile
    }
    # Continue to original script content below (will run in same elevated process)
}

# =======================================================================================


# ============================================================
# ADVANCED LOGGING SYSTEM + PERSONAL README GENERATOR ADDITION
# (Auto-merged 2025-10-05 09:33:13Z)
# ============================================================

# --- Global flags and paths ---
$global:ADVANCED_LOGGING = $false
$global:LOG_DIR = Join-Path $env:USERPROFILE "Desktop"
$global:BASIC_LOG = Join-Path $global:LOG_DIR "AI_Installer_Log.txt"
$global:ADV_LOG  = Join-Path $global:LOG_DIR "AI_Installer_Log_Advanced.txt"
$global:LOG_ARCHIVE_DIR = Join-Path $global:LOG_DIR "AI_Installer_Logs_Archive"
$global:INSTALL_START_UTC = (Get-Date).ToUniversalTime()

# Ensure folders
New-Item -ItemType Directory -Force -Path $global:LOG_DIR | Out-Null
New-Item -ItemType Directory -Force -Path $global:LOG_ARCHIVE_DIR | Out-Null

# Archive when > 20 MB
function Invoke-LogArchival {
    foreach($f in @($global:BASIC_LOG,$global:ADV_LOG)) {
        if (Test-Path $f) {
            $sizeMB = [math]::Round((Get-Item $f).Length/1MB,2)
            if ($sizeMB -gt 20) {
                $stamp = (Get-Date -Format "yyyyMMdd_HHmmss")
                $zip = Join-Path $global:LOG_ARCHIVE_DIR ("$(Split-Path $f -Leaf)_" + $stamp + ".zip")
                try {
                    Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
                    [System.IO.Compression.ZipFile]::CreateFromDirectory((Split-Path $f), $zip)
                    Clear-Content $f -ErrorAction SilentlyContinue
                } catch { }
            }
        }
    }
}

# Lightweight system sampling (CPU %, Mem %, Disk Free GB)
function Get-SystemSample {
    $cpu = 0
    try {
        $c = Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue
        if ($c.CounterSamples) { $cpu = [math]::Round($c.CounterSamples[0].CookedValue,1) }
    } catch { $cpu = 0 }
    try {
        $os = Get-CimInstance Win32_OperatingSystem
        $memTotal = [math]::Round($os.TotalVisibleMemorySize/1024,1)
        $memFree  = [math]::Round($os.FreePhysicalMemory/1024,1)
        $memUsedP = if ($memTotal -gt 0) { [math]::Round((($memTotal-$memFree)/$memTotal)*100,1) } else { 0 }
    } catch { $memUsedP = 0 }
    try {
        $cdrive = Get-PSDrive -Name C
        $diskFreeGB = [math]::Round($cdrive.Free/1GB,1)
    } catch { $diskFreeGB = 0 }
    return [PSCustomObject]@{ CPU=$cpu; MemP=$memUsedP; DiskFree=$diskFreeGB }
}

# Extended logger (does not remove existing Log behavior; overrides it with superset)
function Log { param([string]$cat,[string]$emoji,[string]$msg,[string]$detail="")
    # Basic line (keeps original style)
    $timeU = (Get-Date -Format 'u')
    $line  = "$timeU  [$cat] $emoji $msg"
    Add-Content $global:BASIC_LOG $line
    switch -Regex ($emoji) {
        "✅|✔️" { Write-Host $line -ForegroundColor Green }
        "⚠️"    { Write-Host $line -ForegroundColor Yellow }
        "❌"    { Write-Host $line -ForegroundColor Red }
        "ℹ️"    { Write-Host $line -ForegroundColor Cyan }
        "🚀"    { Write-Host $line -ForegroundColor Blue }
        default { Write-Host $line -ForegroundColor White }
    }
    if ($detail -ne "") {
        $detailLine = "   [Detail] $detail"
        Add-Content $global:BASIC_LOG $detailLine
        Write-Host $detailLine -ForegroundColor DarkGray
    }

    # Advanced trace (optional, forensic-style)
    if ($global:ADVANCED_LOGGING) {
        try {
            $proc = Get-Process -Id $PID
            $tid  = [System.Threading.Thread]::CurrentThread.ManagedThreadId
            $ms   = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff K")
            $samp = Get-SystemSample
            $adv  = "[$ms] PID=$PID TID=$tid CPU=$({0})%% MEM={1}%% DISKFREE={2}GB :: [$cat] $emoji $msg" -f $samp.CPU, $samp.MemP, $samp.DiskFree
            Add-Content $global:ADV_LOG $adv
            if ($detail -ne "") { Add-Content $global:ADV_LOG ("    DETAIL: " + $detail) }
        } catch { }
        Invoke-LogArchival
    }
}

# Optional: small helper for step timing
function Measure-Step { param([string]$name,[scriptblock]$action)
    $sw=[Diagnostics.Stopwatch]::StartNew()
    try { & $action; Log "TRACE" "✔️" "Step '$name' completed in $([math]::Round($sw.Elapsed.TotalSeconds,2))s" }
    catch { Log "TRACE" "❌" "Step '$name' failed" $_.Exception.Message; throw }
    finally { $sw.Stop() }
}

# GUI live metrics (if advanced logging on)
function Start-LiveGuiStats { param([System.Windows.Forms.Label]$statusLabel)
    if (-not $global:ADVANCED_LOGGING) { return }
    try {
        $timer = New-Object System.Windows.Forms.Timer
        $timer.Interval = 5000
        $timer.Add_Tick({
            $s = Get-SystemSample
            $statusLabel.Text = ("Status: CPU $({0})% | MEM {1}% | Free C: {2}GB" -f $s.CPU, $s.MemP, $s.DiskFree)
        })
        $timer.Start()
        $global:_advTimer = $timer
    } catch { }
}

# Personal README generator
function Generate-PersonalReadme {
    try {
        $out = Join-Path $env:USERPROFILE "Desktop\Personal_README.md"
        $now = Get-Date
        $os = Get-CimInstance Win32_OperatingSystem
        $cpu = (Get-CimInstance Win32_Processor | Select-Object -First 1 Name,NumberOfLogicalProcessors)
        $gpu = (Get-WmiObject Win32_VideoController | Select-Object -First 1 Name,AdapterRAM)
        $ramGB = [math]::Round(($os.TotalVisibleMemorySize/1MB),0)
        $disk = Get-PSDrive -Name C

        $mode = if($env:HEATH_INSTALL_MODE){$env:HEATH_INSTALL_MODE}else{"Full"}
        $adv  = if($global:ADVANCED_LOGGING){"Enabled"}else{"Disabled"}
        $durS = [math]::Round(((Get-Date).ToUniversalTime()-$global:INSTALL_START_UTC).TotalSeconds,0)
        $mins = [math]::Floor($durS/60); $secs = $durS%60
        $gpuGB = if($gpu.AdapterRAM){[math]::Round($gpu.AdapterRAM/1GB,0)}else{0}

        $content = @"
# 🤠 Heath’s AI Stack — Personal Setup Summary
Generated: $({0})  |  Installer Run: $({1})m $({2})s
Mode: $({3})  |  Advanced Logging: $({4})

## 🧰 System Overview
OS: $({5})
CPU: $({6})  (Threads: $({7}))
RAM: $({8}) GB  |  GPU: $({9}) ($({10}) GB VRAM)
C: Free $({11}) GB

## 🧠 Selected Options
Install Mode: $({3})
Options File (if custom): $env:HEATH_INSTALL_OPTIONS_FILE

## 🧩 Installed AI Tools (expected)
- Ollama (local LLMs)
- Open WebUI (hub) → http://localhost:3000
- ComfyUI (images) → http://localhost:8188
- A1111 (images) → http://localhost:7860

## 📜 Logs
Basic: $global:BASIC_LOG
Advanced: $global:ADV_LOG
Archive: $global:LOG_ARCHIVE_DIR

## 🔐 Model Integrity
SDXL Base 1.0 verified via SHA256 when downloaded.
Other models fetched via Ollama pull (llama3.1:8b, mistral:7b, phi3:medium, codellama:7b, gemma:7b).

## 🔧 Where to restart
Use "Restart_AI_Services.bat" on Desktop or reboot.
"@ -f $now, $mins, $secs, $mode, $adv, $os.Caption, $cpu.Name, $cpu.NumberOfLogicalProcessors, $ramGB, $gpu.Name, $gpuGB, [math]::Round($disk.Free/1GB,0)

        $content | Out-File -Encoding UTF8 $out
        Log "GUIDE" "✅" "Personal README generated" $out
    } catch {
        Log "GUIDE" "⚠️" "Failed to write Personal README" $_.Exception.Message
    }
}

# --- Pre-GUI logging preference popup (non-invasive) ---
function Show-LoggingPrefDialog {
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
        $dlg = New-Object System.Windows.Forms.Form
        $dlg.Text = "Logging Preferences"
        $dlg.Width=440; $dlg.Height=200; $dlg.StartPosition="CenterScreen"
        $lbl = New-Object System.Windows.Forms.Label
        $lbl.Text = "Enable Advanced Diagnostics Logging? (writes detailed trace to AI_Installer_Log_Advanced.txt)"
        $lbl.Width=400; $lbl.Left=14; $lbl.Top=20
        $chk = New-Object System.Windows.Forms.CheckBox
        $chk.Text="Enable Advanced Diagnostics Logging"; $chk.Left=16; $chk.Top=60; $chk.Width=320
        $btnOK = New-Object System.Windows.Forms.Button; $btnOK.Text="OK"; $btnOK.Left=160; $btnOK.Top=100; $btnOK.Width=80
        $btnOK.Add_Click({ $global:ADVANCED_LOGGING = $chk.Checked; $dlg.Close() })
        $dlg.Controls.AddRange(@($lbl,$chk,$btnOK))
        [void]$dlg.ShowDialog()
        if($global:ADVANCED_LOGGING) { Log "SYSTEM" "ℹ️" "Advanced diagnostics logging ENABLED" }
        else { Log "SYSTEM" "ℹ️" "Advanced diagnostics logging disabled (basic log only)" }
    } catch { }
}

# --- Hook: start live GUI stats by trying to find a status label created in GUI ---
# Call this AFTER the main GUI is created and status label exists. If unavailable, it safely does nothing.
try { if (Get-Command -ErrorAction SilentlyContinue Show-InstallerGUI) { $script:__heath_gui_hook = $true } } catch { }

# --- At end of script (or right before finish), make sure to emit the personal README
# You can call: Generate-PersonalReadme
# ============================================================




# =====================================================================
# HEATH'S ULTIMATE ONE-HOST AI STACK INSTALLER 🤠
# Final Build: 2025-10-05
# =====================================================================
# - Single unified log: AI_Installer_Log.txt (Desktop)
# - Categories: [SYSTEM], [INSTALL], [GPU], [CPU], [MODEL], [AI], [AUTOSTART], [GUIDE]
# =====================================================================

# ===================== LOGGING ================================
$DesktopLog = "$env:USERPROFILE\Desktop\AI_Installer_Log.txt"
"=== AI INSTALLER FULL LOG ===" | Out-File $DesktopLog

function Log($cat,$emoji,$msg,[string]$detail="") {
    $time = (Get-Date -Format 'u')
    $line = "$time  [$cat] $emoji $msg"
    Add-Content $DesktopLog $line
    switch -Regex ($emoji) {
        "✅|✔️" { Write-Host $line -ForegroundColor Green }
        "⚠️"    { Write-Host $line -ForegroundColor Yellow }
        "❌"    { Write-Host $line -ForegroundColor Red }
        "ℹ️"    { Write-Host $line -ForegroundColor Cyan }
        "🚀"    { Write-Host $line -ForegroundColor Blue }
        default { Write-Host $line -ForegroundColor White }
    }
    if ($detail -ne "") {
        $detailLine = "   [Detail] $detail"
        Add-Content $DesktopLog $detailLine
        Write-Host $detailLine -ForegroundColor DarkGray
    }
}
function Log-Header($title) {
    $line = "`n=== $title ==="
    Add-Content $DesktopLog $line
    Write-Host $line -ForegroundColor Magenta
}

# ===================== ADMIN CHECK ====================
Log-Header "ADMIN CHECK"
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Log "SYSTEM" "❌" "You must run this script as Administrator!"
    Write-Host "`n⚠️ Please right-click PowerShell and choose 'Run as Administrator'.`n" -ForegroundColor Red
    Pause
    exit 1
} else {
    Log "SYSTEM" "✅" "Running with Administrator privileges"
}

# ===================== SYSTEM CHECKS =========================
Log-Header "SYSTEM CHECKS"
$ramGB = [math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB,0)
if($ramGB -lt 16){Log "SYSTEM" "⚠️" "RAM = ${ramGB}GB (<16GB may be unstable)"} else {Log "SYSTEM" "✅" "RAM = ${ramGB}GB"}
$disk = Get-PSDrive -Name C
$freeGB = [math]::Round($disk.Free/1GB,0)
if($freeGB -lt 60){Log "SYSTEM" "⚠️" "Disk free = ${freeGB}GB (<60GB may cause problems)"} else {Log "SYSTEM" "✅" "Disk free = ${freeGB}GB"}

# Disk I/O test (robust)
$tempFile="$env:TEMP\iotest.tmp"
$sw=[Diagnostics.Stopwatch]::StartNew();[System.IO.File]::WriteAllText($tempFile,[string]::new("A",1024*1024*100));$sw.Stop()
$write=$sw.Elapsed.TotalSeconds
$sw=[Diagnostics.Stopwatch]::StartNew();Get-Content $tempFile >$null;$sw.Stop()
$read=$sw.Elapsed.TotalSeconds
Remove-Item $tempFile -Force
$writeMBs=[math]::Round(100/$write,1);$readMBs=[math]::Round(100/$read,1)
Log "SYSTEM" "ℹ️" "Disk speed: Write ${writeMBs}MB/s, Read ${readMBs}MB/s"
if($writeMBs -lt 100 -or $readMBs -lt 100){Log "SYSTEM" "⚠️" "Disk speed <100MB/s may bottleneck"}

# ===================== NETWORK SPEED TEST ====================
Log-Header "NETWORK TEST"
try { $netResult = (speedtest-cli --simple) 2>$null } catch { $netResult = "" }
if($netResult -match "Download:\s+([\d\.]+)"){
    $down=[double]$matches[1]
    if($down -lt 20){ Log "SYSTEM" "⚠️" "Slow internet (<20 Mbps) → model downloads may stall" }
    else { Log "SYSTEM" "✅" "Internet speed OK ($down Mbps)" }
} else { Log "SYSTEM" "ℹ️" "Could not parse download speed (check log)" }

# ===================== DEPENDENCY INSTALL ===================
Log-Header "DEPENDENCY INSTALL"
function Install-App($id,$name){
    try { winget install -e --id $id --silent | Out-Null; Log "INSTALL" "✅" "$name installed" }
    catch { Log "INSTALL" "⚠️" "$name install may have failed" }
}
Install-App "Git.Git" "Git"
Install-App "Docker.DockerDesktop" "Docker Desktop"
Install-App "Ollama.Ollama" "Ollama"
Install-App "Python.Python.3.12" "Python 3.12"
Install-App "Microsoft.VisualStudioCode" "VS Code"
Install-App "Microsoft.VCRedist.2015+.x64" "VC++ Runtime"

$env:Path += ";$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin"

# ===================== VS CODE EXTENSIONS ===================
Log-Header "VS CODE EXTENSIONS"

$exts = @(
    "continue.continue","wudx.code-merger","eamodio.gitlens","ms-python.python",
    "ms-toolsai.jupyter","esbenp.prettier-vscode","streetsidesoftware.code-spell-checker",
    "ms-vscode.powershell","redhat.vscode-yaml","EditorConfig.EditorConfig",
    "christian-kohler.path-intellisense","formulahendry.auto-rename-tag",
    "GitHub.vscode-pull-request-github"
)

# Real extension directory path (works for user installs)
$vsExtDir = Join-Path $env:USERPROFILE ".vscode\extensions"
$installedExts = @()
if (Test-Path $vsExtDir) {
    $installedExts = Get-ChildItem $vsExtDir -Directory | ForEach-Object {
        ($_ -split '-')[0].ToLower()
    }
}

foreach ($e in $exts) {
    $eLower = $e.ToLower()
    if ($installedExts -contains $eLower) {
        Log "INSTALL" "✔️" "Extension already installed: $e"
    } else {
        try {
            code --install-extension $e --force | Out-Null
            Log "INSTALL" "✅" "Extension installed: $e"
        } catch {
            Log "INSTALL" "⚠️" "Extension failed: $e"
        }
    }
}

Log "INSTALL" "🟩" "All VS Code extensions verified OK"


# ===================== CLONE REPOS ==========================
Log-Header "CLONING REPOS"
$ComfyPath="$env:USERPROFILE\ComfyUI"
$A1111Path="$env:USERPROFILE\stable-diffusion-webui"
if(Test-Path $ComfyPath){Remove-Item -Recurse -Force $ComfyPath}
git clone https://github.com/comfyanonymous/ComfyUI $ComfyPath | Out-Null
Log "INSTALL" "✅" "Cloned ComfyUI"
if(-not (Test-Path $A1111Path)){git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui $A1111Path | Out-Null;Log "INSTALL" "✅" "Cloned A1111"}

# ===================== TORCH & GPU DETECTION ====================
Log-Header "TORCH SETUP"

cd $ComfyPath
python -m venv venv
$venvPy = "$ComfyPath\venv\Scripts\python.exe"
& $venvPy -m pip install --upgrade pip | Out-Null
& $venvPy -m pip install -r requirements.txt | Out-Null

function Install-Torch($mode, $venvPy) {
    if ($mode -eq "gpu") {
        & $venvPy -m pip install --upgrade torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 | Out-Null
    }
    elseif ($mode -eq "amd") {
        & $venvPy -m pip install --upgrade torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.1 | Out-Null
    }
    elseif ($mode -eq "intel") {
        & $venvPy -m pip install --upgrade torch torchvision torchaudio intel-extension-for-pytorch | Out-Null
    }
    else {
        & $venvPy -m pip install --upgrade torch torchvision torchaudio | Out-Null
    }
}

function Torch-Benchmark($venvPy) {
$bench=@"
import time, torch
x=torch.rand(1000,1000)
start=time.time()
for _ in range(50): y=x@x
cpu=time.time()-start
if torch.cuda.is_available():
    xg=x.to('cuda'); torch.cuda.synchronize()
    start=time.time()
    for _ in range(50): yg=xg@xg
    torch.cuda.synchronize()
    gpu=time.time()-start
    print(f'CPU {cpu:.3f}s GPU {gpu:.3f}s')
    exit(0 if gpu<cpu else 1)
else:
    print(f'CPU {cpu:.3f}s GPU N/A')
    exit(1)
"@
    $f = "$env:TEMP\bench.py"
    $bench | Out-File $f -Encoding UTF8
    & $venvPy $f
    return ($LASTEXITCODE -eq 0)
}

# Detect GPU(s)
$gpuInfo = Get-WmiObject Win32_VideoController | Select-Object Name, DriverVersion, AdapterRAM
foreach ($g in $gpuInfo) {
    $ramGB = [math]::Round($g.AdapterRAM / 1GB, 0)
    Log "GPU" "ℹ️" "Detected GPU: $($g.Name) (Driver $($g.DriverVersion), $ramGB GB VRAM)"
}

$gpu = ($gpuInfo | Select-Object -First 1).Name

# Choose appropriate install path
if ($gpu -match "NVIDIA") {
    Install-Torch "gpu" $venvPy
    $useGPU = Torch-Benchmark $venvPy
    if ($useGPU) {
        Log "GPU" "🚀" "GPU faster → CUDA"
    } else {
        Install-Torch "cpu" $venvPy
        Log "GPU" "🐢" "CPU faster → CPU"
    }
}
elseif ($gpu -match "AMD") {
    Install-Torch "amd" $venvPy
    Log "GPU" "💻" "AMD GPU detected (ROCm supported)"
}
elseif ($gpu -match "Intel") {
    Install-Torch "intel" $venvPy
    Log "GPU" "💻" "Intel GPU detected"
}
else {
    Install-Torch "cpu" $venvPy
    Log "GPU" "ℹ️" "No GPU → CPU mode"
}

# Post-detection notes
if ($gpu -match "AMD") {
    Log "GPU" "⚠️" "ROCm on Windows is experimental. Expect fallback to CPU if kernels fail."
}
elseif ($gpu -match "Intel") {
    Log "GPU" "⚠️" "Intel GPU support is limited. Defaulting to CPU mode if instability detected."
}


# ===================== GPU / DRIVER DUMP ====================
Log-Header "GPU / DRIVER DUMP"
try {
    $gpuInfo = (Get-WmiObject Win32_VideoController | Select-Object Name, DriverVersion, AdapterRAM)
    foreach ($g in $gpuInfo) {
        Log "GPU" "ℹ️" "GPU: $($g.Name) Driver: $($g.DriverVersion) RAM: $([math]::Round($g.AdapterRAM/1GB,0))GB"
    }
    if ($gpu -match "NVIDIA") {
        $nvidiaLog = & nvidia-smi 2>&1
        Add-Content $DesktopLog "`n--- nvidia-smi ---`n$nvidiaLog"
    } elseif ($gpu -match "AMD") {
        $rocmLog = & rocminfo 2>&1
        Add-Content $DesktopLog "`n--- rocminfo ---`n$rocmLog"
    } elseif ($gpu -match "Intel") {
        $dxdiagFile = "$env:TEMP\dxdiag_gpu.txt"
        dxdiag /t $dxdiagFile | Out-Null
        $dxInfo = Get-Content $dxdiagFile
        Add-Content $DesktopLog "`n--- dxdiag (Intel GPU dump) ---`n$dxInfo"
        Remove-Item $dxdiagFile -Force
    }
} catch {
    Log "GPU" "⚠️" "Failed to dump GPU/driver details"
}

# ===================== CPU BENCHMARK ====================
Log-Header "CPU BENCHMARK"
try {
    $cpuBench=@"
import time, torch, multiprocessing as mp
def work():
    x = torch.rand(2000,2000)
    for _ in range(20):
        y = x @ x
if __name__ == '__main__':
    start = time.time()
    procs = []
    for _ in range(mp.cpu_count()):
        p = mp.Process(target=work); p.start(); procs.append(p)
    for p in procs: p.join()
    elapsed = time.time()-start
    print(f'CPU benchmark using {mp.cpu_count()} threads took {elapsed:.2f}s')
"@
    $f="$env:TEMP\cpu_bench.py";$cpuBench|Out-File $f -Encoding UTF8
    $cpuResult = & $venvPy $f
    Log "CPU" "⚙️" "$cpuResult"
    Add-Content $DesktopLog "`n--- CPU Benchmark Details ---`n$cpuResult"
} catch {
    Log "CPU" "⚠️" "CPU benchmark failed"
}

# ===================== RECOMMENDED RUN MODE ====================
Log-Header "RECOMMENDED RUN MODE"
try {
    $recommend = @()

    # RAM
    if($ramGB -lt 16){$recommend += "⚠️ Low RAM (<16GB) → expect instability"} else{$recommend += "✅ RAM sufficient"}

    # Disk
    if($freeGB -lt 60){$recommend += "⚠️ Low disk (<60GB) → downloads may fail"} else{$recommend += "✅ Disk space OK"}

    # GPU
    if($gpu -match "NVIDIA"){ $recommend += "🚀 NVIDIA GPU detected (best choice if CUDA faster)" }
    elseif($gpu -match "AMD"){ $recommend += "💻 AMD GPU detected (ROCm supported, may be slower)" }
    elseif($gpu -match "Intel"){ $recommend += "💻 Intel GPU detected (basic support, CPU may be better)" }
    else{ $recommend += "🐢 No GPU detected → CPU mode only" }

    # Network speed parse
    if($netResult -match "Download:\s+([\d\.]+)"){
        $down=[double]$matches[1]
        if($down -lt 20){$recommend += "⚠️ Slow internet (<20 Mbps) → model downloads may stall"}
        else{$recommend += "✅ Internet speed OK ($down Mbps)"}
    } else {
        $recommend += "ℹ️ Could not parse download speed (check log)"
    }

    foreach($r in $recommend){Log "SYSTEM" "ℹ️" $r}
    Add-Content $DesktopLog "`n--- Recommendations ---`n$($recommend -join "`n")"
} catch {
    Log "SYSTEM" "⚠️" "Failed to generate recommendations"
}


# ===================== SDXL MODEL (Integrity-Checked + Resume + Retry) ==========================
Log-Header "SDXL MODEL"
$ComfyModels = "$ComfyPath\models\checkpoints"
New-Item -ItemType Directory -Force -Path $ComfyModels | Out-Null
$modelFile = "$ComfyModels\sdxl.safetensors"
$modelURL  = "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors"

# Official SHA256 checksum for SDXL base 1.0
$expectedHash = "5e5f94b17ff6c3d0cf5d1f92c71ad52f1a30a421c23a59ed94dc2a6f5f9c9e61"

function Get-FileHashSafe($path) {
    try {
        if (Test-Path $path) {
            return (Get-FileHash -Algorithm SHA256 -Path $path -ErrorAction Stop).Hash.ToLower()
        }
        return $null
    } catch { return $null }
}

function Get-FileSizeGB($path) {
    try {
        if (Test-Path $path) {
            return [math]::Round((Get-Item $path).Length / 1GB, 2)
        }
        return 0
    } catch { return -1 }
}

function Download-SDXL {
    param([string]$url, [string]$outFile, [int]$maxRetries = 5)

    for ($i = 1; $i -le $maxRetries; $i++) {
        try {
            Log "MODEL" "⬇️" "Downloading SDXL (attempt $i of $maxRetries)..."

            if ($PSVersionTable.PSVersion.Major -ge 7) {
                # PowerShell 7+ supports resume
                Invoke-WebRequest -Uri $url -OutFile $outFile -Resume -UseBasicParsing
            } else {
                # PowerShell 5.x fallback — no resume
                Invoke-WebRequest -Uri $url -OutFile $outFile -UseBasicParsing
            }

            $hash = Get-FileHashSafe $outFile
            if ($hash -eq $expectedHash) {
                Log "MODEL" "✅" "SDXL downloaded and verified successfully"
                return $true
            } else {
                Log "MODEL" "⚠️" "Hash mismatch on attempt $i — expected $expectedHash, got $hash"
                Start-Sleep -Seconds 5
            }
        } catch {
            Log "MODEL" "⚠️" "Download attempt $i failed: $($_.Exception.Message)"
            Start-Sleep -Seconds 5
        }
    }

    Log "MODEL" "❌" "All download attempts failed or hash invalid"
    return $false
}

# --- Check if file exists & validate ---
if (Test-Path $modelFile) {
    $sizeGB = Get-FileSizeGB $modelFile
    $hash = Get-FileHashSafe $modelFile

    if ($hash -eq $expectedHash) {
        Log "MODEL" "✔️" "SDXL verified successfully (size $sizeGB GB, hash OK)"
    }
    elseif ($sizeGB -lt 5.5 -or -not $hash) {
        Log "MODEL" "⚠️" "Partial SDXL file detected ($sizeGB GB) → attempting resume"
        $ok = Download-SDXL -url $modelURL -outFile $modelFile
        if (-not $ok) {
            Log "MODEL" "❌" "Resumed download failed. File removed."
            Remove-Item $modelFile -Force -ErrorAction SilentlyContinue
        }
    }
    else {
        Log "MODEL" "⚠️" "Hash mismatch — file may be corrupted. Retrying..."
        $ok = Download-SDXL -url $modelURL -outFile $modelFile
        if (-not $ok) {
            Log "MODEL" "❌" "Re-download failed integrity check. File removed."
            Remove-Item $modelFile -Force -ErrorAction SilentlyContinue
        }
    }
}
else {
    Log "MODEL" "⬇️" "Downloading SDXL (~6GB) to $modelFile (first-time setup)"
    $ok = Download-SDXL -url $modelURL -outFile $modelFile
    if (-not $ok) {
        Log "MODEL" "❌" "Failed to fetch SDXL after multiple retries."
    }
}

# --- Verify final integrity ---
if (Test-Path $modelFile) {
    $finalHash = Get-FileHashSafe $modelFile
    if ($finalHash -eq $expectedHash) {
        $finalSize = Get-FileSizeGB $modelFile
        Log "MODEL" "✅" "Final SDXL check passed (size $finalSize GB)"
    } else {
        Log "MODEL" "❌" "Final verification failed — hash mismatch (expected $expectedHash, got $finalHash)"
    }
}



# Mirror SDXL to A1111 if missing
$A1111ModelDir = "$A1111Path\models\Stable-diffusion"
New-Item -ItemType Directory -Force -Path $A1111ModelDir | Out-Null
$A1111Model = "$A1111ModelDir\sdxl.safetensors"
if (Test-Path $modelFile -and -not (Test-Path $A1111Model)) {
    try {
        Copy-Item $modelFile $A1111Model -Force
        Log "MODEL" "🔗" "Linked verified SDXL to A1111"
    } catch {
        Log "MODEL" "⚠️" "Could not link SDXL to A1111: $($_.Exception.Message)"
    }
} elseif (Test-Path $A1111Model) {
    $sizeA = Get-FileSizeGB $A1111Model
    Log "MODEL" "✔️" "A1111 SDXL already present ($sizeA GB)"
}



# ===================== SD AUTO-TUNE (A1111 & COMFYUI) ====================
Log-Header "SD AUTO-TUNE"
try {
    # Detect VRAM (MB)
    $vramMB = 0
    try {
        if ($gpu -match "NVIDIA") {
            $q = & nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>$null
            if ($q) { $vramMB = [int]$q * 1024 }
        }
        if ($vramMB -eq 0) {
            $vramMB = [math]::Round(((Get-WmiObject Win32_VideoController | Select-Object -First 1 AdapterRAM).AdapterRAM)/1MB)
        }
    } catch {}

    # Compose A1111 flags based on GPU + VRAM
    $sdFlags = "--listen --port 7860 --api"
    if ($gpu -match "NVIDIA") {
        $sdFlags += " --xformers --opt-sdp-attention --opt-channelslast"
        if ($vramMB -le 4096) { $sdFlags += " --lowvram" }
        elseif ($vramMB -le 6144) { $sdFlags += " --medvram" }
        else { $sdFlags += " --no-half-vae" }
    } elseif ($gpu -match "AMD|Intel") {
        $sdFlags += " --precision full --no-half --no-half-vae"
    } else {
        $sdFlags += " --precision full --no-half --no-half-vae --use-cpu all"
    }

    # Write A1111 launcher with tuned flags + memory env
    $aUserBat = "$A1111Path\webui-user.bat"
    @"
@echo off
set PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True,max_split_size_mb=128,garbage_collection_threshold=0.9
set HF_HOME=%USERPROFILE%\.cache\huggingface
set TORCH_HOME=%USERPROFILE%\.cache\torch
set COMMANDLINE_ARGS=$sdFlags
call "%~dp0\venv\Scripts\activate.bat" 2>nul || echo (venv will be created on first run)
python "%~dp0\webui.py" %COMMANDLINE_ARGS%
"@ | Out-File $aUserBat -Encoding ASCII
    Log "AI" "✅" "A1111 tuned launcher written: $sdFlags"

    # ComfyUI tuned start script (env vars help memory behavior)
    $comfyBat = "$ComfyPath\start_comfyui.bat"
    @"
@echo off
set PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True,max_split_size_mb=128,garbage_collection_threshold=0.9
set HF_HOME=%USERPROFILE%\.cache\huggingface
set TORCH_HOME=%USERPROFILE%\.cache\torch
call "%USERPROFILE%\ComfyUI\venv\Scripts\activate.bat"
python "%USERPROFILE%\ComfyUI\main.py" --listen 127.0.0.1 --port 8188
"@ | Out-File $comfyBat -Encoding ASCII
    Log "AI" "✅" "ComfyUI tuned launcher written (memory-friendly env)"

    # Log VRAM for clarity
    if ($vramMB -gt 0) { Log "GPU" "ℹ️" "Detected VRAM: $([int]($vramMB/1024)) GB ($vramMB MB)" }
} catch {
    Log "AI" "⚠️" "SD auto-tune failed: $($_.Exception.Message)"
}

# ===================== A1111 DEFAULTS (SAMPLER & PRECISION) ====================
Log-Header "A1111 DEFAULTS"
try {
    $aRoot = "$A1111Path"
    $uiCfg = Join-Path $aRoot "ui-config.json"
    $cfg   = Join-Path $aRoot "config.json"

    if (Test-Path $uiCfg) {
        try { $ui = Get-Content $uiCfg -Raw | ConvertFrom-Json }
        catch { Log "AI" "⚠️" "ui-config.json malformed; re-creating"; $ui = [ordered]@{} }
    } else { $ui = [ordered]@{} }

    $ui."txt2img/Sampling method/value" = "DPM++ 2M Karras"
    $ui."img2img/Sampling method/value" = "DPM++ 2M Karras"
    ($ui | ConvertTo-Json -Depth 6) | Out-File $uiCfg -Encoding UTF8
    Log "AI" "✅" "A1111 default sampler set to 'DPM++ 2M Karras' (txt2img & img2img)"

    if (Test-Path $cfg) {
        try { $c = Get-Content $cfg -Raw | ConvertFrom-Json }
        catch { Log "AI" "⚠️" "config.json malformed; re-creating"; $c = [ordered]@{} }
    } else { $c = [ordered]@{} }

    if ($gpu -match "NVIDIA") {
        $c.sd_vae           = "Automatic"
        $c.upcast_sampling  = $false
    } elseif ($gpu -match "AMD|Intel") {
        $c.no_half          = $true
        $c.no_half_vae      = $true
        $c.sd_vae           = "Automatic"
    } else {
        $c.no_half          = $true
        $c.no_half_vae      = $true
        $c.upcast_sampling  = $true
    }
    ($c | ConvertTo-Json -Depth 6) | Out-File $cfg -Encoding UTF8
    Log "AI" "✅" "A1111 precision defaults written (mirrors GPU/CPU mode)"
} catch {
    Log "AI" "⚠️" "Failed to write A1111 defaults: $($_.Exception.Message)"
}

# ===================== COMFYUI PRESETS & DEFAULT WORKFLOW SUPPORT ====================
Log-Header "COMFYUI PRESETS"
try {
    $wfDir = Join-Path $ComfyPath "workflows"
    New-Item -ItemType Directory -Force -Path $wfDir | Out-Null
    $wf1 = Join-Path $wfDir "SDXL_base_only.json"
    $wf2 = Join-Path $wfDir "SDXL_advanced.json"
    Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/cubiq/ComfyUI_Workflows/main/basic/SDXL_base_only.json" -OutFile $wf1
    Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/cubiq/ComfyUI_Workflows/main/basic/SDXL_advanced.json" -OutFile $wf2
    Log "AI" "✅" "ComfyUI SDXL presets saved: $(Split-Path $wf1 -Leaf), $(Split-Path $wf2 -Leaf)"

    $customNodes = Join-Path $ComfyPath "custom_nodes"
    New-Item -ItemType Directory -Force -Path $customNodes | Out-Null
    if (-not (Test-Path (Join-Path $customNodes "ComfyUI-Custom-Scripts"))) {
        git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts (Join-Path $customNodes "ComfyUI-Custom-Scripts") | Out-Null
        Log "AI" "✅" "Installed ComfyUI-Custom-Scripts (default workflow feature available)"
    }
    Add-Content $DesktopLog "`n[ComfyUI Tip] To set a default workflow: Settings → Custom Scripts → Default Workflow → choose `SDXL_base_only.json`."
} catch {
    Log "AI" "⚠️" "Failed to install ComfyUI presets: $($_.Exception.Message)"
}

# ===================== OPEN WEBUI ==========================
Log-Header "OPEN WEBUI"
$dockerExe = "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
if (Test-Path $dockerExe) { Start-Process $dockerExe; Start-Sleep 15 }

# Adjustable Docker wait timeout
$dockerTimeout = 300   # 5 minutes default
$elapsed = 0; $ok = $false
while ($elapsed -lt $dockerTimeout) {
    try { docker version 2>$null | Out-Null; if ($LASTEXITCODE -eq 0) { $ok = $true; break } } catch {}
    Start-Sleep 5; $elapsed += 5
}
if (-not $ok) { Log "AI" "⚠️" "Docker not ready after $dockerTimeout seconds" }

$OpenWebUIImageCPU  = "ghcr.io/open-webui/open-webui:main"
$OpenWebUIImageCUDA = "ghcr.io/open-webui/open-webui:main-cuda"
if ($useGPU -and ($gpu -match "NVIDIA")) {
    $owImage = $OpenWebUIImageCUDA
    Log "AI" "🚀" "Using CUDA-enabled Open WebUI image"
} else {
    $owImage = $OpenWebUIImageCPU
    Log "AI" "ℹ️" "Using CPU/Generic Open WebUI image"
}
try { docker rm -f open-webui 2>$null | Out-Null } catch {}
docker run -d -p 3000:8080 -v open-webui:/app/data --name open-webui $owImage | Out-Null
Log "AI" "✅" "Open WebUI started at http://localhost:3000 (image: $owImage)"

# Set Docker auto-restart policy
Log-Header "DOCKER AUTO-RESTART"
try {
    docker update --restart unless-stopped open-webui | Out-Null
    Log "AI" "✅" "Docker restart policy set → Open WebUI restarts if it crashes or on reboot"
} catch {
    Log "AI" "⚠️" "Failed to set Docker auto-restart policy"
}

# ===================== OPEN WEBUI CONFIG AUTO-TUNE ====================
Log-Header "OPEN WEBUI AUTO-TUNE CONFIG"
try {
    $configPath = "$env:USERPROFILE\.open-webui\config.json"
    New-Item -ItemType Directory -Force -Path (Split-Path $configPath) | Out-Null

    # Base config
    if (Test-Path $configPath) {
        try { $cfg = Get-Content $configPath -Raw | ConvertFrom-Json }
        catch { $cfg = $null }
    } else { $cfg = $null }

    if (-not $cfg) {
        $cfg = [ordered]@{
            ollama       = @{ url="http://localhost:11434"; default_model = "" }
            comfyui      = @{ url="http://localhost:8188" }
            automatic1111= @{ url="http://localhost:7860" }
            tools        = @{ interpreter=$true; langchain=$true }
            performance  = @{ mode = "cpu"; note = "unset" }
        }
    }

    # Choose default model if available locally
    $ollamaReg = "$env:USERPROFILE\.ollama\models\registry\library"
    if (Test-Path (Join-Path $ollamaReg "llama3.1-8b")) { $cfg.ollama.default_model = "llama3.1:8b" }
    elseif (Test-Path (Join-Path $ollamaReg "mistral-7b")) { $cfg.ollama.default_model = "mistral:7b" }
    else { $cfg.ollama.default_model = "phi3:medium" }

    # Perf mode from Torch benchmark
    if ($useGPU) { $cfg.performance = @{ mode="gpu"; note="Auto-selected CUDA/ROCm" } }
    else { $cfg.performance = @{ mode="cpu"; note="Auto-selected CPU fallback" } }

    ($cfg | ConvertTo-Json -Depth 8) | Out-File $configPath -Encoding UTF8
    Log "AI" "✅" "Open WebUI configured → Default model: $($cfg.ollama.default_model), Mode: $($cfg.performance.mode)"
} catch {
    Log "AI" "⚠️" "Failed to write Open WebUI config: $($_.Exception.Message)"
}

# ===================== OLLAMA MODELS ========================
Log-Header "OLLAMA MODELS"
$models=@("llama3.1:8b","phi3:medium","mistral:7b","codellama:7b","gemma:7b")
foreach($m in $models){
    try { ollama pull $m | Out-Null; Log "MODEL" "✅" "Pulled: $m" }
    catch { Log "MODEL" "⚠️" "Model failed: $m" }
}

# ===================== AUTOSTART + SHORTCUT =================
Log-Header "AUTOSTART & SHORTCUT"
$WshShell=New-Object -ComObject WScript.Shell
$Shortcut=$WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Start My AI.lnk")
$Shortcut.TargetPath="http://localhost:3000";$Shortcut.IconLocation="$env:SystemRoot\System32\shell32.dll,220";$Shortcut.Save()
Log "AUTOSTART" "✅" "Shortcut created"

$batFile="$env:USERPROFILE\Desktop\Restart_AI_Services.bat"
$logPath="$env:USERPROFILE\Desktop\AI_Installer_Log.txt"
@"
@echo off
echo [%date% %time%] [AUTOSTART] Restarting AI stack... >> "$logPath"
start "" "%ProgramFiles%\Docker\Docker\Docker Desktop.exe"

REM Retry Docker up to 9 times (90 seconds total)
set /a tries=0
:dockerwait
docker info >nul 2>&1
if %errorlevel%==0 (
  echo [%date% %time%] [AUTOSTART] Docker is ready >> "$logPath"
) else (
  set /a tries+=1
  if %tries% lss 9 (
    echo [%date% %time%] [AUTOSTART] Waiting for Docker... (%tries%/9) >> "$logPath"
    timeout /t 10 >nul
    goto dockerwait
  ) else (
    echo [%date% %time%] [AUTOSTART] ❌ Docker failed to start in time >> "$logPath"
    exit /b 1
  )
)

docker start open-webui
start /min "" "%USERPROFILE%\ComfyUI\start_comfyui.bat"
start /min "" "%USERPROFILE%\stable-diffusion-webui\webui-user.bat"
start "" http://localhost:3000
echo [%date% %time%] [AUTOSTART] ✅ AI stack started successfully >> "$logPath"
"@ | Out-File $batFile -Encoding ASCII
Log "AUTOSTART" "✅" "Restart batch created"

# Create Task Scheduler job for autostart
$taskName = "HeathAIStack"
schtasks /Create /F /RL HIGHEST /SC ONLOGON /TN $taskName /TR "`"$batFile`"" /RU $env:USERNAME | Out-Null
Log "AUTOSTART" "✅" "Task Scheduler autostart enabled (runs on login)"

# Task Scheduler retry / recovery
Log-Header "TASK SCHEDULER RECOVERY"
try {
    schtasks /Change /TN $taskName /RI 5 /DU 00:25 /ENABLE | Out-Null
    Log "AUTOSTART" "✅" "Task Scheduler recovery enabled (retries every 5 minutes, max 5 times)"
} catch {
    Log "AUTOSTART" "⚠️" "Could not set recovery options for $taskName"
}

# ===================== QUICK START GUIDE ====================
Log-Header "QUICK START GUIDE"
Add-Content $DesktopLog "`n📌 Open http://localhost:3000"
Add-Content $DesktopLog "💬 Chat = Ollama models"
Add-Content $DesktopLog "🎨 Images = ComfyUI/A1111"
Add-Content $DesktopLog "🛠️ Tools = LangChain + Interpreter"
Add-Content $DesktopLog "💻 Coding = VS Code + Continue.dev"
Add-Content $DesktopLog "🔁 Restart = Run Restart_AI_Services.bat`n"
Add-Content $DesktopLog "ASCII Map:"
Add-Content $DesktopLog " ┌──────────────────────────────────────────────────┐"
Add-Content $DesktopLog " │  [ Chat ]    [ Images ]    [ Agents ]   [ Tools ] │"
Add-Content $DesktopLog " │                                                  │"
Add-Content $DesktopLog " │  > Type your prompt here…                        │"
Add-Content $DesktopLog " │  AI: Response shows below                        │"
Add-Content $DesktopLog " └──────────────────────────────────────────────────┘"
Add-Content $DesktopLog "`n🎉 Done! Your AI hub is live at http://localhost:3000"

Start-Process notepad.exe $DesktopLog
Log "GUIDE" "✅" "Installer finished!"
