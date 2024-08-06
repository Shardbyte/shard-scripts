<!--
#
#
###########################
#                         #
#  Saint @ Shardbyte.com  #
#                         #
###########################
# Author: Shardbyte (Saint)
#
#
-->

<div id="header" align="center">
  <img src="https://raw.githubusercontent.com/Shardbyte/Shardbyte/main/img/logo-shardbyte-master-light.webp" alt="logo-shardbyte" width="150"/>
</div>

---

# EFT-SPT Mod and BepInEx Plugin Updater

This PowerShell script automates the process of updating EFT-SPT mods and BepInEx plugins. It moves outdated mods and plugins to a backup folder, downloads the latest versions from a specified GitHub repository, and places them in the correct directories. The script also ensures that necessary files and folders are present before proceeding.

## Features

- **Backup**: Moves outdated mods and plugins to a backup folder.
- **Update**: Downloads and installs the latest versions of mods and plugins from a GitHub repository.
- **Configuration**: Updates specific configuration settings in the `boot.config` file.
- **Git Management**: Installs Git if not already installed, and optionally uninstalls it after use.

## Prerequisites

- Administrative privileges may be required.
- Internet connection to download updates and Git.

## Script Details

- **Author**: Shardbyte (@Shardbyte)
- **Version**: 0.0.9
- **GitHub Repository**: [Shardbyte/shard-scripts/eft-util](https://github.com/Shardbyte/shard-scripts/eft-util)

## Usage

1. **Run the Script**: Execute the script in a PowerShell window with administrative privileges.
2. **Backup**: The script will move outdated mod and plugin folders to a backup directory named `eftutil-backup` in the base folder.
3. **Update**: The script will clone the latest mod and plugin files from the specified GitHub repository and copy them to the appropriate directories.
4. **Configuration**: The script will update the `job-worker-count` setting in the `EscapeFromTarkov_Data\boot.config` file to optimize performance.
5. **Git Management**: If Git is not installed, the script will download and install it. After the update process, the script will prompt whether to uninstall Git.

## File and Folder Structure

- **Required Files**:
  - `SPT.Server.exe`
  - `SPT.Launcher.exe`
  - `EscapeFromTarkov.exe`

- **Required Folders**:
  - `user\mods`
  - `BepInEx\plugins`
  - `BepInEx\config`
  - `SPT_Data\Server\configs`
  - `EscapeFromTarkov_Data`

## Notes

- This script is designed to simplify the process of updating EFT-SPT mods and BepInEx plugins.
- Ensure you have a backup of your current configuration before running the script.

For more information and the latest updates, visit the [GitHub repository](https://github.com/Shardbyte/shard-scripts/eft-util).

## License

MIT License

Copyright (c) 2024 Shardbyte

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
