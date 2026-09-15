#!/usr/bin/env bash
# Cambiar estado del micrófono por defecto
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

# Obtener estado y volumen del micrófono
raw=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)
is_muted=$(echo "$raw" | grep -o "\[MUTED\]")
vol_decimal=$(echo "$raw" | awk '{print $2}')

if [ -n "$vol_decimal" ]; then
    vol=$(awk -v v="$vol_decimal" 'BEGIN { printf "%.0f", v * 100 }')
else
    vol=0
fi

if [ "$is_muted" = "[MUTED]" ]; then
    # Envía notificación de silenciado reemplazando la anterior
    notify-send -e -h string:x-canonical-private-synchronous:mic-status \
        -u low -i audio-input-microphone-muted "Micrófono" "Silenciado "
else
    # Envía notificación de activo mostrando el porcentaje
    notify-send -e -h string:x-canonical-private-synchronous:mic-status \
        -u low -i audio-input-microphone "Micrófono" "Activo: ${vol}% "
fi

# Actualizar el icono en Waybar al instante
pkill -RTMIN+11 waybar 2>/dev/null || true
