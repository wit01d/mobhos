#!/data/data/com.termux/files/usr/bin/bash

# Log file for debugging
STATIC_IP_LOG="/data/data/com.termux/files/home/ip-static.log"

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
    
    echo -e "${color}[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message${NC}" >> "$STATIC_IP_LOG"
}

# Configuration
INTERFACE="wlan1"
STATIC_IP="192.168.1.100"
STATIC_NETMASK="255.255.255.1"
STATIC_GATEWAY="192.168.1.101"

# Additional configuration
DNS_PRIMARY="8.8.8.8"
DNS_SECONDARY="8.8.4.4"

setup_static_ip() {
    # Flush network settings
    ip addr flush dev $INTERFACE
    log "INFO" "Flushed interface $INTERFACE"
    
    log "INFO" "Setting up static IP on interface $INTERFACE"

    # Set static IP
    ifconfig $INTERFACE down
    log "INFO" "Interface $INTERFACE down"
    
    ifconfig $INTERFACE $STATIC_IP netmask $STATIC_NETMASK up
    log "INFO" "Setting IP: $STATIC_IP with netmask: $STATIC_NETMASK"
    
    route add default gw $STATIC_GATEWAY $INTERFACE
    log "INFO" "Adding default gateway: $STATIC_GATEWAY"

    # Add DNS configuration
    echo "nameserver $DNS_PRIMARY" > /etc/resolv.conf
    echo "nameserver $DNS_SECONDARY" >> /etc/resolv.conf
    log "INFO" "Configured DNS servers"

    # Get actual values
    ACTUAL_IP=$(ifconfig $INTERFACE | grep 'inet ' | awk '{print $2}')
    ACTUAL_NETMASK=$(ifconfig $INTERFACE | grep 'inet ' | awk '{print $4}')
    ACTUAL_GATEWAY=$(route -n | grep '^0.0.0.0' | grep $INTERFACE | awk '{print $2}')

    # Check if all values match
    if [ "$ACTUAL_IP" = "$STATIC_IP" ] && [ "$ACTUAL_NETMASK" = "$STATIC_NETMASK" ] && [ "$ACTUAL_GATEWAY" = "$STATIC_GATEWAY" ]; then
        log "SUCCESS" "Static IP setup successful"
        log "INFO" "Current config - IP: $ACTUAL_IP, Netmask: $ACTUAL_NETMASK, Gateway: $ACTUAL_GATEWAY"
        
        # Verify connectivity
        if ping -c 3 $STATIC_GATEWAY >/dev/null 2>&1; then
            log "SUCCESS" "Network connectivity verified"
            return 0
        fi
    fi
    
    log "ERROR" "Static IP setup failed"
    return 1
}

# Main execution
setup_static_ip || exit 1