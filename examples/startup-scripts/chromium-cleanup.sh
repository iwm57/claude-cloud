#!/bin/sh
# Chromium Cleanup Startup Script
# Place this in /workspace/context/scripts/startup/chromium-cleanup.sh
# It will be automatically run on container start

# Create the cleanup script
cat > /usr/local/bin/clean-chromium.sh << 'CLEANUP_SCRIPT'
#!/bin/sh
# Kill chromiums older than 10 minutes, run hourly
while true; do
  for pid in $(pidof chromium 2>/dev/null); do
    elapsed=$(echo $(($(date +%s) - $(stat -c %Y /proc/$pid 2>/dev/null))))
    if [ "$elapsed" -gt 600 ]; then
      kill -9 $pid 2>/dev/null && echo "$(date) Killed chromium PID $pid (age: ${elapsed}s)" >> /var/log/chromium-clean.log
    fi
  done
  sleep 3600
done
CLEANUP_SCRIPT

chmod +x /usr/local/bin/clean-chromium.sh

# Start the cleanup script in background
nohup /usr/local/bin/clean-chromium.sh >> /var/log/chromium-clean.log 2>&1 &

echo "Chromium cleanup script installed and started"
