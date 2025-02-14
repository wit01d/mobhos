#!/data/data/com.termux/files/usr/bin/sh

# Set up logging
LOG_FILE="/data/data/com.termux/files/home/startup.log"
echo "================== $(date) ==================" >> "$LOG_FILE"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Enhanced logging function with colors
log() {
    local level="$1"
    local message="$2"
    local color=""
    
    case "$level" in
        "ERROR") color="$RED" ;;
        "INFO")  color="$BLUE" ;;
        "WARN")  color="$YELLOW" ;;
        "SUCCESS") color="$GREEN" ;;
        *) color="$NC" ;;
    esac
    
    echo -e "${color}[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message${NC}" >> "$LOG_FILE"
}

# Function to run and log command status
run_command() {
    local command_name="$1"
    local command="$2"
    
    if eval "$command"; then
        log "SUCCESS" "$command_name: SUCCESS"
        return 0
    else
        log "ERROR" "$command_name: FAILED"
        return 1
    fi
}

# Wait for system to initialize
sleep 10
log "INFO" "System initialized after boot"

# Run commands with proper logging
run_command "Wake Lock" "termux-wake-lock"
# run_command "Static IP" "sudo ~/ip-static.sh"
run_command "SSHD" "sshd"
run_command "Nginx" "sudo nginx"
run_command "Tunneling" "sudo ~/tunneling.sh"
run_command "Nginx Reload" "sudo nginx -s reload"
