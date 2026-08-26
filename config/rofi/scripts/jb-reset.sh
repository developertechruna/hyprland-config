#!/bin/bash
# Rofi launcher for JetBrains Trial Reset

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JB_RESET="${SCRIPT_DIR}/../target/release/jb-reset"

# Check if jb-reset is built
if [ ! -f "$JB_RESET" ]; then
    JB_RESET="jb-reset"  # Try system-wide installation
fi

# Get product list in rofi format
selection=$(${JB_RESET} list --rofi | rofi -dmenu -i -p "Reset JetBrains Trial" -theme-str 'window {width: 600px;}')

if [ -n "$selection" ]; then
    # Extract product name (first word)
    product=$(echo "$selection" | awk '{print tolower($2)}' | sed 's/[^a-z]//g')
    
    # Confirm reset
    confirm=$(echo -e "Yes\nNo" | rofi -dmenu -p "Reset $product trial?" -theme-str 'window {width: 300px;}')
    
    if [ "$confirm" = "Yes" ]; then
        # Perform reset
        ${JB_RESET} reset "$product"
        
        # Show notification
        if [ $? -eq 0 ]; then
            notify-send "Trial Reset" "$product trial has been reset successfully" -i jetbrains-toolbox
        else
            notify-send "Trial Reset Failed" "Failed to reset $product" -i dialog-error
        fi
    fi
fi
