# ==============================================================================
# Borno (বর্ণ) - 1-Line Windows Automated Installer
# Developed & Maintained by Yahia Bin Zaman
# ==============================================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host " ======================================================= " -ForegroundColor Green
Write-Host "   🌟 Borno (বর্ণ) — Bengali Input Method for Windows   " -ForegroundColor Cyan
Write-Host "   Developed & Maintained by Yahia Bin Zaman            " -ForegroundColor Gray
Write-Host " ======================================================= " -ForegroundColor Green
Write-Host ""

$Repo = "yahiabinzaman/borno-keyboard"
$InstallDir = "$env:LOCALAPPDATA\Programs\Borno"
if (!(Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
}

$BornoExe = Join-Path $InstallDir "Borno.exe"

Write-Host "[-] Fetching latest Borno release for Windows..." -ForegroundColor Yellow

try {
    # Default direct asset URL
    $DownloadUrl = "https://github.com/$Repo/releases/download/v0.2.5/Borno.exe"

    # Dynamic asset detection if available
    try {
        $ApiUrl = "https://api.github.com/repos/$Repo/releases/latest"
        $ReleaseData = Invoke-RestMethod -Uri $ApiUrl -Headers @{"User-Agent"="Borno-Installer"}
        $Asset = $ReleaseData.assets | Where-Object { $_.name -like "*Borno*.exe" } | Select-Object -First 1
        if ($Asset) {
            $DownloadUrl = $Asset.browser_download_url
        }
    } catch {
        # Fallback to direct release URL
    }

    Write-Host "[-] Downloading Borno ($DownloadUrl)..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $BornoExe -UseBasicParsing

    # Create Desktop and Startup shortcuts
    $WshShell = New-Object -ComObject WScript.Shell
    
    # Desktop Shortcut
    $DesktopShortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Borno.lnk")
    $DesktopShortcut.TargetPath = $BornoExe
    $DesktopShortcut.Description = "Borno Bengali Keyboard"
    $DesktopShortcut.Save()

    # Startup Shortcut (Auto-start)
    $StartupFolder = [Environment]::GetFolderPath("Startup")
    $StartupShortcut = $WshShell.CreateShortcut("$StartupFolder\Borno.lnk")
    $StartupShortcut.TargetPath = $BornoExe
    $StartupShortcut.Description = "Borno Bengali Keyboard"
    $StartupShortcut.Save()

    Write-Host ""
    Write-Host "[✓] Borno (বর্ণ) has been installed successfully to $InstallDir!" -ForegroundColor Green
    Write-Host "[✓] Press F12 anytime in any application to toggle English ⇋ Bengali." -ForegroundColor Green
    Write-Host ""

    # Launch Borno
    Start-Process -FilePath $BornoExe

} catch {
    Write-Host "[!] Installation failed: $_" -ForegroundColor Red
    Write-Host "[-] Please download Borno.exe manually from: https://github.com/$Repo/releases" -ForegroundColor Yellow
}
