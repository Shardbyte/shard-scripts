#!/usr/bin/env bash
###########################
#                         #
#  Saint @ Shardbyte.com  #
#                         #
###########################
# Copyright (c) 2023-2024 Shardbyte
# Author: Shardbyte (Saint)
# License: MIT
# https://github.com/Shardbyte/shard-scripts/raw/main/LICENSE
######  BEGIN FILE  ###### ######  BEGIN FILE  ###### ######  BEGIN FILE  ######
#
# ----- This script will install ZSH -----
# ----- This script uses shard-dotfiles -----
#


# -------------------- Variables -------------------- #

CM="${GN}✓${CL}"                                                                                   # Checkmark (Success)
CROSS="${RD}✗${CL}"                                                                                # Cross (Error)
RD=$(echo "\033[01;31m")                                                                            # Red Text
YW=$(echo "\033[33m")                                                                               # Yellow Text
GN=$(echo "\033[1;92m")                                                                             # Green Text
CL=$(echo "\033[m")                                                                                 # Reset Text
BFR="\\r\\033[K"                                                                                    # Clear Line
HOLD="[INFO]"                                                                                       # State Header
DISTRO=$(grep -oP '^ID=\K.*' /etc/os-release)                                                       # Distro Identification

# -------------------- Error Handling -------------------- #

set -euo pipefail
shopt -s inherit_errexit nullglob

# -------------------- Information Messages -------------------- #

msg_info() {
  local msg="$1"
  echo -ne " ${GN}${HOLD}${CL} ${YW}${msg}${CL}\n"
}

msg_ok() {
  local msg="$1"
  echo -e "${BFR} ${CM} ${GN}${msg}${CL}\n"
}

msg_error() {
  local msg="$1"
  echo -e "${BFR} ${CROSS} ${RD}${msg}${CL}\n"
}

# ------------------ Start Script ----------------- #

install_packages() {
    local PACKAGES="$@"
    case "$DISTRO" in
        "debian" | "ubuntu")
            sudo apt update -y
            sudo apt upgrade -y
            sudo apt install -y $PACKAGES
            ;;
        "fedora")
            sudo dnf update -y
            sudo dnf upgrade -y
            sudo dnf install -y $PACKAGES
            ;;
        *)
            msg_error "Unsupported distribution. Please install the packages manually..."
            ;;
    esac
}

install() {
    PACKAGE=$1
    CODE=$2
    if ! command -v "$PACKAGE" > /dev/null 2>&1; then
        msg_info "Starting installation of $PACKAGE..."
        eval "$CODE"
    else
        msg_error "$PACKAGE is already installed"
    fi
}

install_utilities() {
    local DISTRO="$1"

    local ubuntu_packages="zsh git"
    local debian_packages="zsh git"
    local fedora_packages="zsh git"

    case "$DISTRO" in
        "ubuntu")
            msg_info "Installing some utilities on Ubuntu..."
            install_packages "$ubuntu_packages"
            ;;
        "debian")
            msg_info "Installing some utilities on Debian..."
            install_packages "$debian_packages"
            ;;
        "fedora")
            msg_info "Installing some utilities on Fedora..."
            install_packages "$fedora_packages"
            ;;
        *)
            msg_error "Unsupported distribution. Please install the packages manually..."
            ;;
    esac
}

install_zsh_and_oh_my_zsh() {
    local ZSH_ZSHRC="$HOME/.zshrc"
    local ZSH_INSTALLED="$HOME/.oh-my-zsh"

    # Install custom .zshrc if not already installed
    if [ ! -f "$ZSH_ZSHRC" ]; then
        msg_info "Installing custom .zshrc..."
        curl -fsSL -o "$ZSH_ZSHRC" https://raw.githubusercontent.com/Shardbyte/shard-dotfiles/master/.oh-my-zsh/.zshrc
    else
        msg_error "Custom .zshrc is already installed"
    fi

    # Install Oh My Zsh if not already installed
    if [ ! -d "$ZSH_INSTALLED" ]; then
        msg_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        msg_error "Oh My Zsh is already installed"
    fi

    # Revert from default .zshrc if a backup exists
    if [ -f "$HOME/.zshrc.pre-oh-my-zsh" ]; then
        msg_info "Reverting to default .zshrc..."
        sudo rm -rf "$HOME/.zshrc" \
        && cp "$HOME/.zshrc.pre-oh-my-zsh" "$HOME/.zshrc" \
        && sudo rm "$HOME/.zshrc.pre-oh-my-zsh"
    else
        msg_error "Backup of default .zshrc does not exist"
    fi

    # Make Zsh the default shell if it is not already
    if [ "$SHELL" != "$(which zsh)" ]; then
        msg_info "Setting Zsh as the default shell..."
        chsh -s "$(which zsh)"
    else
        msg_error "Zsh is already the default shell"
    fi
}

start_routines() {
    install_utilities "$DISTRO"
    install_zsh_and_oh_my_zsh
}

start_routines
msg_ok "All functions have been successfully completed!"