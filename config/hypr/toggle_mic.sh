#!/usr/bin/env bash
# Cambiar estado del micrófono por defecto
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

# Verificar si quedó silenciado
is_muted=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -o "\[MUTED\]")

if [ "$is_muted" = "[MUTED]" ]; then
    # Envía notificación de silenciado reemplazando la anterior
    notify-send -e -h string:x-canonical-private-synchronous:mic-status \
        -u low -i audio-input-microphone-muted "Micrófono" "Silenciado "
else
    # Envía notificación de activo
    notify-send -e -h string:x-canonical-private-synchronous:mic-status \
        -u low -i audio-input-microphone "Micrófono" "Activo "
fi
