#!/data/data/com.termux/files/usr/bin/bash

# Log file for debugging
TUNNELING_LOG="/data/data/com.termux/files/home/tunneling.log"

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
    
    echo -e "${color}[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message${NC}" >> "$TUNNELING_LOG"
}

# Function to check and configure ping_group_range
configure_ping_group() {
    local current_gid=$(id -g)
    local range_file="/proc/sys/net/ipv4/ping_group_range"
    
    log "INFO" "Checking ping_group_range configuration..."
    
    # Check if we can access the file
    if [ ! -r "$range_file" ]; then
        log "WARN" "Cannot read ping_group_range file, attempting to set permissions"
        sudo chmod 644 "$range_file"
    fi
    
    # Read current range
    if [ -r "$range_file" ]; then
        local range=$(cat "$range_file")
        local min_gid=$(echo $range | awk '{print $1}')
        local max_gid=$(echo $range | awk '{print $2}')
        
        if [ "$current_gid" -lt "$min_gid" ] || [ "$current_gid" -gt "$max_gid" ]; then
            log "INFO" "Current GID ($current_gid) not in ping_group_range ($min_gid $max_gid)"
            # Set new range to include current GID
            echo "0 $((current_gid + 1000))" | sudo tee "$range_file" > /dev/null
            log "SUCCESS" "Updated ping_group_range"
        else
            log "INFO" "GID already in valid range"
        fi
    else
        log "WARN" "Could not configure ping_group_range"
    fi
}

# Function to start cloudflared
start_cloudflared() {
    log "INFO" "Starting tunneling..."
    
    # Configure ping_group before starting cloudflared
    configure_ping_group
    
    cloudflared tunnel --config /data/data/com.termux/files/home/.cloudflared/config.yml --loglevel debug run mobile >> "$TUNNELING_LOG" 2>&1 &
    
    # Store the PID
    local PID=$!
    echo $PID > /data/data/com.termux/files/home/.cloudflared/.tunneling.pid
    log "INFO" "Tunneling PID: $PID"
    
    # Wait for initialization
    sleep 5
    
    # Check if process is still running
    if ! kill -0 "$PID" 2>/dev/null; then
        log "ERROR" "Failed to start tunneling - process died"
        return 1
    fi
    
    # Check logs for errors
    if grep -i "error\|failed" "$TUNNELING_LOG" | grep -v "Removing OLD_PID" > /dev/null; then
        log "ERROR" "Errors found in tunnel log"
        return 1
    fi
    
    log "INFO" "Tunneling started successfully"
    return 0
}

# Check if cloudflared is already running
if [ -f "/data/data/com.termux/files/home/.cloudflared/.tunneling.pid" ]; then
    OLD_PID=$(cat /data/data/com.termux/files/home/.cloudflared/.tunneling.pid)
    if kill -0 "$OLD_PID" 2>/dev/null; then
        log "INFO" "Tunneling already running with PID: $OLD_PID"
        exit 0
    else
        log "INFO" "Removing stale PID file"
        rm /data/data/com.termux/files/home/.cloudflared/.tunneling.pid
    fi
fi

if start_cloudflared; then
    exit 0
else
    exit 1
fi