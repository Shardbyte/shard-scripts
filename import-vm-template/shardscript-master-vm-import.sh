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
# ----- his script will download a cloud image and deploy it as a template in Proxmox VE -----
# ----- Tested on Proxmox VE 8.2.4 -----
#

# -------------------- Message Variables -------------------- #

CM="${GN}✓${CL}"                                                                                   # Checkmark (Success)
CROSS="${RD}✗${CL}"                                                                                # Cross (Error)
RD=$(echo "\033[01;31m")                                                                            # Red Text
YW=$(echo "\033[33m")                                                                               # Yellow Text
GN=$(echo "\033[1;92m")                                                                             # Green Text
CL=$(echo "\033[m")                                                                                 # Reset Text
BFR="\\r\\033[K"                                                                                    # Clear Line
HOLD="[INFO]"                                                                                       # State Header

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

# ------------------ Default Variable Values ----------------- #

MEMORY="2048"
DISK_SIZE="10G"
# Change "shard-disks" to your desired storage location
STORAGE="shard-disks"
NET_IFACE="vmbr0"

# ------------------ Template Selection Menu ----------------- #

msg_info "Select a Linux image to deploy a template in Proxmox:"
PS3="Select an option [1-10]: "
OPTIONS=(
  "Ubuntu Server Minimal 20.04 LTS"
  "Ubuntu Server Minimal 22.04 LTS"
  "Ubuntu Server Minimal 24.04 LTS"

  "Debian 11"
  "Debian 12"

  "Fedora Cloud 39"
  "Fedora Cloud 40"
  "Fedora Server 40"

  "Arch Linux 2024.07.01"

  "Quit"
)

# ------------------ Selectable Template Options ----------------- #

select opt in "${OPTIONS[@]}"; do
  case "${opt}" in
  "Ubuntu Server Minimal 20.04 LTS")
    msg_info "You selected Ubuntu Server Minimal 20.04 LTS"
    msg_info "Downloading cloud image..."
    # https://cloud-images.ubuntu.com/minimal/releases/focal/release/SHA256SUMS
    IMAGE="https://cloud-images.ubuntu.com/minimal/releases/focal/release/ubuntu-20.04-minimal-cloudimg-amd64.img"
    DST="ubuntu-20.04-minimal-cloudimg-amd64.img"
    ID_VM=50901
    VM_NAME="template-ubuntu-20"
    break
    ;;
  "Ubuntu Server Minimal 22.04 LTS")
    msg_info "You selected Ubuntu Server Minimal 22.04 LTS"
    msg_info "Downloading cloud image..."
    # https://cloud-images.ubuntu.com/minimal/releases/jammy/release/SHA256SUMS
    IMAGE="https://cloud-images.ubuntu.com/minimal/releases/jammy/release/ubuntu-22.04-minimal-cloudimg-amd64.img"
    DST="ubuntu-22.04-minimal-cloudimg-amd64.img"
    ID_VM=50902
    VM_NAME="template-ubuntu-22"
    break
    ;;
  "Ubuntu Server Minimal 24.04 LTS")
    msg_info "You selected Ubuntu Server Minimal 24.04 LTS"
    msg_info "Downloading cloud image..."
    # https://cloud-images.ubuntu.com/minimal/releases/noble/release/SHA256SUMS
    IMAGE="https://cloud-images.ubuntu.com/minimal/releases/noble/release/ubuntu-24.04-minimal-cloudimg-amd64.img"
    DST="ubuntu-24.04-minimal-cloudimg-amd64.img"
    ID_VM=50903
    VM_NAME="template-ubuntu-24"
    break
    ;;
  "Debian 11")
    msg_info "You selected Debian 11"
    msg_info "Downloading cloud image..."
    # https://cloud.debian.org/images/cloud/bullseye/latest/SHA512SUMS
    IMAGE="https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-nocloud-amd64.qcow2"
    DST="debian-11-nocloud-amd64.qcow2"
    ID_VM=50904
    VM_NAME="template-debian-11"
    break
    ;;
  "Debian 12")
    msg_info "You selected Debian 12"
    msg_info "Downloading cloud image..."
    # https://cloud.debian.org/images/cloud/bookworm/latest/SHA512SUMS
    IMAGE="https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-nocloud-amd64.qcow2"
    DST="debian-12-nocloud-amd64.qcow2"
    ID_VM=50905
    VM_NAME="template-debian-12"
    break
    ;;
  "Fedora Cloud 39")
    msg_info "You selected Fedora Cloud 39"
    msg_info "Downloading cloud image..."
    # https://fedora.ipacct.com/fedora/linux/releases/39/Cloud/x86_64/images/Fedora-Cloud-39-1.5-x86_64-CHECKSUM
    IMAGE="https://download.fedoraproject.org/pub/fedora/linux/releases/39/Cloud/x86_64/images/Fedora-Cloud-Base-39-1.5.x86_64.qcow2"
    DST="Fedora-Cloud-Base-39-1.5.x86_64.qcow2"
    ID_VM=50906
    VM_NAME="template-fedora-39"
    break
    ;;
  "Fedora Cloud 40")
    msg_info "You selected Fedora Cloud 40"
    msg_info "Downloading cloud image..."
    # https://fedora.ipacct.com/fedora/linux/releases/40/Cloud/x86_64/images/Fedora-Cloud-40-1.14-x86_64-CHECKSUM
    IMAGE="https://fedora.ipacct.com/fedora/linux/releases/40/Cloud/x86_64/images/Fedora-Cloud-Base-Generic.x86_64-40-1.14.qcow2"
    DST="Fedora-Cloud-Base-Generic.x86_64-40-1.14.qcow2"
    ID_VM=50907
    VM_NAME="template-fedora-40"
    break
    ;;
  "Fedora Server 40")
    msg_info "You selected Fedora Server 40"
    msg_info "Downloading server image..."
    # https://fedora.ipacct.com/fedora/linux/releases/40/Server/x86_64/images/Fedora-Server-40-1.14-x86_64-CHECKSUM
    IMAGE="https://fedora.ipacct.com/fedora/linux/releases/40/Server/x86_64/images/Fedora-Server-KVM-40-1.14.x86_64.qcow2"
    DST="Fedora-Server-KVM-40-1.14.x86_64.qcow2"
    ID_VM=50908
    VM_NAME="template-fedora-server-40"
    break
    ;;
  "Arch Linux 2024.07.01")
    msg_info "You selected Arch Linux 2024.07.01"
    msg_info "Downloading cloud image..."
    # https://geo.mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-cloudimg.qcow2.SHA256
    IMAGE="https://geo.mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-cloudimg.qcow2"
    DST="Arch-Linux-x86_64-cloudimg.qcow2"
    ID_VM=50909
    VM_NAME="template-arch-2024-07-01"
    break
    ;;
  "Quit")
    exit 0
    ;;
  *)
    msg_error "Invalid option, try again."
    ;;
  esac
done


# ------------------ Start Script ----------------- #


# Download image
wget -O "${DST}" "${IMAGE}"
msg_info "Uploading cloud image to Proxmox..."

# Create a VM with the cloud image and convert to template
qm create "${ID_VM}" --name "${VM_NAME}" --memory "${MEMORY}" --net0 virtio,bridge="${NET_IFACE}" --scsihw virtio-scsi-pci
# Set description
qm set "${ID_VM}" --description "This VM was created from the template:<br>'${VM_NAME}'"
# Set agent and cpu parameters
qm set "${ID_VM}" --agent enabled=1,fstrim_cloned_disks=1 --cpu cputype=host
# Import cloud image to VM
qm set "${ID_VM}" --scsi0 "${STORAGE}":0,import-from="${PWD}"/"${DST}"
# Set cloud-init parameters
qm set "${ID_VM}" --ide2 "${STORAGE}":cloudinit
qm set "${ID_VM}" --boot order=scsi0
qm set "${ID_VM}" --serial0 socket --vga serial0
# Set network parameters
qm set "${ID_VM}" --ipconfig0 ip=dhcp
# Set disk size
qm disk resize "${ID_VM}" scsi0 "${DISK_SIZE}"
msg_info "Creating cloud template in Proxmox..."

# Convert VM to template
qm template "${ID_VM}"
msg_info "Cleaning up..."

# Remove downloaded image
rm -Rf "${DST}"
msg_ok "Template successfully created!"
