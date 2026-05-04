#!/bin/bash
set -e

echo "====================================="
echo " Setting up Weekly Background Updates"
echo "====================================="

# We use the raw path in case the user hasn't run deploy.sh yet
FETCH_SCRIPT="$PWD/base/.local/bin/system-update-fetch"
CRON_SCHEDULE="0 10 * * 1" # 10:00 AM every Monday

if [[ "$(uname)" == "Darwin" ]]; then
    echo "Configuring macOS user crontab..."
    
    if crontab -l 2>/dev/null | grep -q "system-update-fetch"; then
        echo "→ Cronjob is already configured."
    else
        (crontab -l 2>/dev/null; echo "$CRON_SCHEDULE $FETCH_SCRIPT") | crontab -
        echo "✅ macOS cronjob successfully installed!"
        echo "⚠️  NOTE: macOS restricts cron for security. You must go to:"
        echo "   System Settings -> Privacy & Security -> Full Disk Access"
        echo "   and grant access to 'cron' or your Terminal."
    fi
else
    echo "Configuring Linux system-wide cron (/etc/cron.d)..."
    echo "This requires sudo so the background job can run pacman/dnf as root."
    
    TEMP_CRON="/tmp/system-update-fetch-cron"
    # Create the cron entry running as 'root' so it has permissions to download packages
    echo "$CRON_SCHEDULE root $FETCH_SCRIPT" > "$TEMP_CRON"
    
    sudo mv "$TEMP_CRON" /etc/cron.d/system-update-fetch
    sudo chown root:root /etc/cron.d/system-update-fetch
    sudo chmod 644 /etc/cron.d/system-update-fetch
    
    echo "✅ Linux root cronjob successfully installed!"
fi

echo "====================================="
echo "Updates will now silently fetch every Monday at 10 AM."
echo "Log file: /tmp/system-update-fetch.log"
echo "====================================="
