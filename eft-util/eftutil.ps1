<#
#################################################
# Copyright (c) Shardbyte. All Rights Reserved. #
# SPDX-License-Identifier: MIT                  #
#################################################
.NOTES
        Author         : Shardbyte @Shardbyte
        GitHub         : https://github.com/Shardbyte
        Version        : 0.0.9
.LINK
        Project Site   : https://github.com/Shardbyte/shard-scripts/eft-util
#######################################################
.SYNOPSIS
        Moves outdated EFT-SPT mods/bepinex folders to a backup folder and downloads and places the latest versions in the correct folders.
.DESCRIPTION
        This script is designed to be straightforward and easy to use, removing the hassle of manually downloading, installing, and configuring EFT-SPT mods/bepinex plugins.
    This script may need to be run with administrative privileges.
#>

# Welcome text
Write-Host "Available on Github: https://github.com/Shardbyte/shard-scripts/eft-util" -ForegroundColor Green

# Github repository of latest files
$repoUrl = "https://github.com/Shardbyte/shard-eft.git"
# Base folder location
$baseFolder = (Get-Location).Path

# Backup folder location
$backupFolder = "$baseFolder\eftutil-backup"

# File to edit and the setting to change
$fileToEdit = "EscapeFromTarkov_Data\boot.config"
$settingToEdit = "job-worker-count="

# Required files
$requiredFiles = @(
    "SPT.Server.exe",
    "SPT.Launcher.exe",
    "EscapeFromTarkov.exe"
)

# Required folders
$requiredFolders = @(
    "$baseFolder\user\mods",
    "$baseFolder\BepInEx\plugins",
    "$baseFolder\BepInEx\config",
    "$baseFolder\SPT_Data\Server\configs",
    "$baseFolder\EscapeFromTarkov_Data"
)

# Required folders to move (for backup)
$foldersToMove = @(
    "$baseFolder\user\mods",
    "$baseFolder\BepInEx\plugins",
    "$baseFolder\BepInEx\config",
    "$baseFolder\SPT_Data\Server\configs"
)

# Required folders to move from the Git repository
$foldersToCopy = @(
    "user\mods",
    "BepInEx\plugins",
    "BepInEx\config",
    "SPT_Data\Server\configs"
)

$filesToMove = @(
    "EscapeFromTarkov_Data\boot.config"
)

# Check if the required files exist in the same folder as the script
$missingFiles = $requiredFiles | Where-Object { -not (Test-Path -Path (Join-Path $baseFolder $_)) }
if ($missingFiles.Count -gt 0) {
    Write-Host "The following required files are missing:" -ForegroundColor Red
    $missingFiles | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    exit 1
}

# Check if the required folders exist in the same folder as the script
$missingFolders = $requiredFolders | Where-Object { -not (Test-Path -Path $_) }
if ($missingFolders.Count -gt 0) {
    Write-Host "The following required folders are missing:" -ForegroundColor Red
    $missingFolders | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    exit 1
}

# Function to install the latest version of Git
function Install-Git {
    $gitReleasesUrl = "https://api.github.com/repos/git-for-windows/git/releases/latest"
    $installerPath = "$env:TEMP\Git-Installer.exe"

    Write-Host "Fetching latest Git release information..." -ForegroundColor Green
    $latestRelease = Invoke-RestMethod -Uri $gitReleasesUrl -Headers @{ "User-Agent" = "PowerShell" }

    $gitInstallerUrl = $latestRelease.assets | Where-Object { $_.name -match "Git-.*-64-bit.exe" } | Select-Object -ExpandProperty browser_download_url

    Write-Host "Downloading Git installer..." -ForegroundColor Green
    Invoke-WebRequest -Uri $gitInstallerUrl -OutFile $installerPath

    Write-Host "Installing Git..." -ForegroundColor Green
    Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT", "/NORESTART" -Wait

    Remove-Item $installerPath

    Write-Host "Git installation completed." -ForegroundColor Green
}

# Function to uninstall Git
function Uninstall-Git {
    $gitUninstallerPath = "C:\Program Files\Git\unins000.exe"

    if (Test-Path $gitUninstallerPath) {
        Write-Host "Uninstalling Git..." -ForegroundColor Yellow
        Start-Process -FilePath $gitUninstallerPath -ArgumentList "/VERYSILENT", "/NORESTART" -Wait
        Write-Host "Git uninstallation completed." -ForegroundColor Green
    } else {
        Write-Host "Git uninstaller not found." -ForegroundColor Red
    }
}

# Check if Git is installed, and install it if not
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git is not installed. Installing Git..." -ForegroundColor Yellow
    Install-Git

    # Refresh the session to recognize the new Git installation
    $env:Path += ";C:\Program Files\Git\cmd"
    [Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)
}

# Create the backup folder if it doesn't exist
if (-not (Test-Path $backupFolder)) {
    New-Item -ItemType Directory -Path $backupFolder | Out-Null
}

# Move the specific folders to the backup folder
foreach ($folder in $foldersToMove) {
    if (Test-Path $folder) {
        $destination = Join-Path $backupFolder (Split-Path $folder -Leaf)
        Move-Item -Path $folder -Destination $destination -Force
    } else {
        Write-Host "Folder $folder does not exist." -ForegroundColor Red
    }
}

# Move the specific files to the backup folder
foreach ($file in $filesToMove) {
    $sourcePath = Join-Path $baseFolder $file
    if (Test-Path $sourcePath) {
        $destination = Join-Path $backupFolder (Split-Path $file -Leaf)
        Move-Item -Path $sourcePath -Destination $destination -Force
    } else {
        Write-Host "File $sourcePath does not exist." -ForegroundColor Red
    }
}

# Clone the repository to a temporary folder
$tempFolder = "$env:TEMP\git-repo"
if (Test-Path $tempFolder) {
    Remove-Item -Path $tempFolder -Recurse -Force
}
git clone $repoUrl $tempFolder

# Copy the specified folders from the temporary folder to the base folder
foreach ($folder in $foldersToCopy) {
    $sourcePath = Join-Path $tempFolder $folder
    $destinationPath = Join-Path $baseFolder $folder

    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $destinationPath -Recurse -Force
    } else {
        Write-Host "Folder $sourcePath does not exist in the repository." -ForegroundColor Yellow
    }
}

# Get the total number of cores and calculate max value
$totalCores = (Get-WmiObject -Class Win32_Processor).NumberOfCores
$maxValue = $totalCores - 2

# Edit the configuration file
$configFilePath = Join-Path $tempFolder $fileToEdit
if (Test-Path $configFilePath) {
    (Get-Content $configFilePath) -replace "$settingToEdit\d+", "${settingToEdit}${maxValue}" | Set-Content $configFilePath
    Copy-Item -Path $configFilePath -Destination (Join-Path $baseFolder $fileToEdit) -Force
    Write-Host "Configuration file has been successfully updated." -ForegroundColor Green
} else {
    Write-Host "Configuration file $configFilePath does not exist in the repository." -ForegroundColor Red
}

# Remove the temporary folder
Remove-Item $tempFolder -Recurse -Force

# Prompt user for Git uninstallation
$uninstallGit = Read-Host "Do you want to uninstall Git after use? (yes/no)"
if ($uninstallGit -eq "yes") {
    Uninstall-Git
}

Write-Host "The script has successfully finished." -ForegroundColor Green
