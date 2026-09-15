#!/usr/bin/env bash
# ==========================================
# Monitor de estado de energía (Batería / Corriente) con notificaciones
# Ubicación destino: ~/.config/hypr/power_notify.sh
# ==========================================

# Identificar rutas del adaptador de corriente y batería
AC_PATH="/sys/class/power_supply/AC/online"
if [ ! -f "$AC_PATH" ]; then
    AC_PATH=$(ls /sys/class/power_supply/*/online 2>/dev/null | head -n 1)
fi

BAT_CAP_PATH="/sys/class/power_supply/BAT0/capacity"
if [ ! -f "$BAT_CAP_PATH" ]; then
    BAT_CAP_PATH=$(ls /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1)
fi

get_ac_state() {
    if [ -n "$AC_PATH" ] && [ -f "$AC_PATH" ]; then
        cat "$AC_PATH" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

get_battery_capacity() {
    if [ -n "$BAT_CAP_PATH" ] && [ -f "$BAT_CAP_PATH" ]; then
        cat "$BAT_CAP_PATH" 2>/dev/null || echo ""
    else
        echo ""
    fi
}

send_notification() {
    local state="$1"
    local cap
    cap=$(get_battery_capacity)
    local cap_text=""
    if [ -n "$cap" ]; then
        cap_text=" (${cap}%)"
    fi

    if [ "$state" = "1" ]; then
        notify-send -e -h string:x-canonical-private-synchronous:power-status \
            -u low -i battery-charging "Energía" "Conectado a corriente${cap_text} 󰂄"
    else
        notify-send -e -h string:x-canonical-private-synchronous:power-status \
            -u normal -i battery "Energía" "Desconectado de corriente${cap_text} 󰁹"
    fi
}

last_state=$(get_ac_state)

# Escuchar eventos de energía en tiempo real
if command -v upower >/dev/null 2>&1; then
    upower --monitor | while read -r _; do
        current_state=$(get_ac_state)
        if [ "$current_state" != "$last_state" ]; then
            send_notification "$current_state"
            last_state="$current_state"
        fi
    done
else
    # Modo polling fallback si upower no está disponible
    while true; do
        current_state=$(get_ac_state)
        if [ "$current_state" != "$last_state" ]; then
            send_notification "$current_state"
            last_state="$current_state"
        fi
        sleep 2
    done
fi
