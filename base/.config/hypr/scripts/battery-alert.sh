#!/bin/bash

# --- VARIABLES ---
# Automatically find the battery path (Asahi uses macsmc-battery)
BATTERY_PATH=$(upower -e | grep battery | head -n 1)

# Flags to track if we have already alerted the user
SENT_20=false
SENT_10=false

while true; do
  # Get the current status and percentage
  STATUS=$(upower -i "$BATTERY_PATH" | grep state | awk '{print $2}')
  PERCENT=$(upower -i "$BATTERY_PATH" | grep percentage | awk '{print $2}' | tr -d '%')

  # Ensure we actually got a number (safety check)
  if [[ -z "$PERCENT" ]]; then
    sleep 60
    continue
  fi

  # --- LOGIC ---
  if [[ "$STATUS" == "discharging" ]]; then

    # CRITICAL ALERT (10% or less)
    if [[ "$PERCENT" -le 10 ]]; then
      if [[ "$SENT_10" == "false" ]]; then
        # -u critical makes it stick on screen longer (depending on dunst config)
        notify-send -u critical "Battery Critical" "Level is at ${PERCENT}%. Connect charger immediately."
        SENT_10=true
        SENT_20=true
      fi

    # LOW ALERT (20% or less)
    elif [[ "$PERCENT" -le 20 ]]; then
      if [[ "$SENT_20" == "false" ]]; then
        notify-send -u normal "Battery Low" "Level is at ${PERCENT}%."
        SENT_20=true
      fi
    fi

  else
    # If charging or fully-charged, reset the flags so alerts work next time
    if [[ "$STATUS" == "charging" ]] || [[ "$STATUS" == "fully-charged" ]]; then
      SENT_20=false
      SENT_10=false
    fi
  fi

  # Check again in 60 seconds
  sleep 60
done
