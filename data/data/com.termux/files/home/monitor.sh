#!/data/data/com.termux/files/usr/bin/bash

echo "=== Memory Usage ==="
free -h

echo -e "\n=== Storage Usage ==="
df -h

echo -e "\n=== Top Processes ==="
ps aux | head -n 6