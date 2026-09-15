#!/usr/bin/env bash
# Script para mostrar el estado y nivel del micrófono en Waybar
# Ubicación original destino: ~/.config/waybar/mic.sh

raw=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)
if [ -z "$raw" ]; then
    echo '{"text": "󰍭", "tooltip": "Micrófono no detectado", "class": "muted"}'
    exit 0
fi

is_muted=$(echo "$raw" | grep -o "\[MUTED\]")
vol_decimal=$(echo "$raw" | awk '{print $2}')

# Calcular porcentaje entero a partir del decimal de wpctl
if [ -n "$vol_decimal" ]; then
    vol=$(awk -v v="$vol_decimal" 'BEGIN { printf "%.0f", v * 100 }')
else
    vol=0
fi

if [ "$is_muted" = "[MUTED]" ]; then
    icon="󰍭"
    class="muted"
    tooltip="Micrófono: ${vol}% (Silenciado)"
elif [ "$vol" -le 0 ]; then
    icon="󰍮" # Solo contorno cuando está en 0%
    class="zero"
    tooltip="Micrófono: ${vol}%"
else
    icon="󰍬" # Relleno completo cuando tiene volumen (>0%)
    class="active"
    tooltip="Micrófono: ${vol}%"
fi

echo "{\"text\": \"$icon\", \"tooltip\": \"$tooltip\", \"class\": \"$class\", \"percentage\": $vol}"
