#!/data/data/com.termux/files/usr/bin/bash

# Setup log file
LOG_FILE="/data/data/com.termux/files/home/setup.log"
echo "================== Setup Started $(date) ==================" >> "$LOG_FILE"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logging function
log() {
    echo -e "${2}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}" | tee -a "$LOG_FILE"
}

# Check environment variables
if [ -z "$IP_ADDRESS" ]; then
    log "Error: IP_ADDRESS not set" "$RED"
    exit 1
fi

# Function to install package groups
install_group() {
    local group_name="$1"
    shift
    local packages=("$@")

    log "Installing $group_name packages..." "$YELLOW"
    if pkg install -y --upgrade "${packages[@]}"; then
        log "$group_name installation complete" "$GREEN"
    else
        log "$group_name installation failed" "$RED"
        return 1
    fi
}

# Update package repositories
log "Updating package repositories..." "$YELLOW"
termux-change-repo

# Package groups
base_packages=(root-repo apt bash-completion bash busybox bzip2 ca-certificates command-not-found coreutils dash debianutils dialog diffutils dos2unix dpkg ed file findutils)
system_libs=(libandroid-glob libandroid-selinux libandroid-support libassuan libbz2 "libc++" libcap-ng libcrypt libcurl libdb libedit libevent libgcrypt libgmp libgnutls libgpg-error libiconv libidn2 liblz4 liblzma libmd libmpfr libnettle libnghttp2 libnghttp3 libnpth libresolv-wrapper libsmartcols libssh2 libtalloc libtirpc libunbound libunistring)
utils_packages=(gawk gpgv grep gzip htop less lsof nano ncurses-utils ncurses patch pcre2 procps psmisc readline resolv-conf sed tar termux-am-socket unzip util-linux xxhash xz-utils zlib zstd)
network_packages=(inetutils net-tools iproute2 wireless-tools wpa-supplicant nmap krb5 ldns)
security_packages=(openssh openssh-sftp-server openssl gnupg termux-auth)
termux_packages=(proot-distro proot runit termux-am termux-api termux-api-static termux-exec termux-keyring termux-licenses termux-services termux-tools tsu)
dev_packages=(vim wget tmux neofetch android-tools)
service_packages=(nginx cloudflared cronie mount-utils)

# Install all package groups
pkg update -y

install_group "Base" "${base_packages[@]}"
install_group "System Libraries" "${system_libs[@]}"
install_group "Utilities" "${utils_packages[@]}"
install_group "Network" "${network_packages[@]}"
install_group "Security" "${security_packages[@]}"
install_group "Termux" "${termux_packages[@]}"
install_group "Development" "${dev_packages[@]}"
install_group "Services" "${service_packages[@]}"

# Configure network
log "Configuring network interface..." "$YELLOW"
if sudo ip addr add "$IP_ADDRESS/24" dev wlan1; then
    log "Network configuration successful" "$GREEN"
else
    log "Network configuration failed" "$RED"
fi

# Setup services
log "Setting up services..." "$YELLOW"
mkdir -p ~/.termux/boot
chmod +x ~/.termux/boot/startup.sh
sv-enable crond
sv up crond


if sv status crond; then
    log "Cron service is running" "$GREEN"
else
    log "Cron service failed to start" "$RED"
fi

termux-reload-settings

log "Setup completed successfully" "$GREEN"
