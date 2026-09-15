# ==============================================================================
# Borno (বর্ণ) - 1-Line Windows Automated Installer
# Developed & Maintained by Yahia Bin Zaman
# ==============================================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host " ======================================================= " -ForegroundColor Green
Write-Host "   🌟 Borno (বর্ণ) — Avro Phonetic Bengali for Windows   " -ForegroundColor Cyan
Write-Host "   Developed & Maintained by Yahia Bin Zaman            " -ForegroundColor Gray
Write-Host " ======================================================= " -ForegroundColor Green
Write-Host ""

$Repo = "yahiabinzaman/borno-keyboard"
$InstallDir = "$env:LOCALAPPDATA\Programs\Borno"
$TempDir = [System.IO.Path]::GetTempPath()
$SetupExe = Join-Path $TempDir "Borno-Setup.exe"

Write-Host "[-] Fetching latest Borno release from GitHub..." -ForegroundColor Yellow

try {
    # Fetch latest release URL
    $ReleaseUrl = "https://github.com/$Repo/releases/download/v0.2.5/Borno-Setup-0.2.5.exe"
    
    # Try getting dynamic latest release asset if available
    try {
        $ApiUrl = "https://api.github.com/repos/$Repo/releases/latest"
        $ReleaseData = Invoke-RestMethod -Uri $ApiUrl -Headers @{"User-Agent"="Borno-Installer"}
        $Asset = $ReleaseData.assets | Where-Object { $_.name -like "*Setup*.exe" -or $_.name -like "*.exe" } | Select-Object -First 1
        if ($Asset) {
            $ReleaseUrl = $Asset.browser_download_url
        }
    } catch {
        # Fallback to direct release URL
    }

    Write-Host "[-] Downloading Borno ($ReleaseUrl)..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $ReleaseUrl -OutFile $SetupExe -UseBasicParsing

    Write-Host "[-] Installing Borno..." -ForegroundColor Cyan
    # Run installer silently or with standard wizard
    Start-Process -FilePath $SetupExe -ArgumentList "/SILENT /DIR=`"$InstallDir`"" -Wait

    Write-Host ""
    Write-Host "[✓] Borno (বর্ণ) has been installed successfully!" -ForegroundColor Green
    Write-Host "[✓] Press F12 anytime to switch English ⇋ Bengali mode." -ForegroundColor Green
    Write-Host ""

    # Start Borno if installed
    $BornoExe = Join-Path $InstallDir "Borno.exe"
    if (Test-Path $BornoExe) {
        Start-Process -FilePath $BornoExe
    }

} catch {
    Write-Host "[!] Installation failed: $_" -ForegroundColor Red
    Write-Host "[-] Please download the installer manually from: https://github.com/$Repo/releases" -ForegroundColor Yellow
}
