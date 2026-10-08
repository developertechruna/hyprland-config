#!/usr/bin/env bash
# ==========================================
# Monitor de estado de energía (Batería / Corriente) con notificaciones
# Ubicación destino: ~/.config/hypr/power_notify.sh
# ==========================================

# Garantizar instancia única por sesión de usuario mediante bloqueo exclusivo
exec 200>"/tmp/power_notify_${USER}.lock"
if ! flock -n 200; then
    exit 0
fi

# Identificar rutas del adaptador de corriente y batería en sysfs
AC_PATH="/sys/class/power_supply/AC/online"
if [ ! -f "$AC_PATH" ]; then
    AC_PATH=$(ls /sys/class/power_supply/*/online 2>/dev/null | head -n 1)
fi

BAT_CAP_PATH="/sys/class/power_supply/BAT0/capacity"
if [ ! -f "$BAT_CAP_PATH" ]; then
    BAT_CAP_PATH=$(ls /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1)
fi

BAT_STATUS_PATH="/sys/class/power_supply/BAT0/status"
if [ ! -f "$BAT_STATUS_PATH" ]; then
    BAT_STATUS_PATH=$(ls /sys/class/power_supply/BAT*/status 2>/dev/null | head -n 1)
fi

# Umbrales de batería (%)
LOW_BAT_THRESHOLD=20      # Advertencia preventiva
CRIT_BAT_THRESHOLD=10     # Alerta crítica
DANGER_BAT_THRESHOLD=5    # Apagado / suspensión inminente por agotamiento

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

get_battery_status() {
    if [ -n "$BAT_STATUS_PATH" ] && [ -f "$BAT_STATUS_PATH" ]; then
        cat "$BAT_STATUS_PATH" 2>/dev/null || echo ""
    else
        echo ""
    fi
}

play_sound() {
    local sound="$1"
    if command -v canberra-gtk-play >/dev/null 2>&1; then
        canberra-gtk-play -i "$sound" 2>/dev/null &
    elif [ -f "/usr/share/sounds/freedesktop/stereo/${sound}.oga" ] && command -v pw-play >/dev/null 2>&1; then
        pw-play "/usr/share/sounds/freedesktop/stereo/${sound}.oga" 2>/dev/null &
    elif [ -f "/usr/share/sounds/freedesktop/stereo/${sound}.oga" ] && command -v paplay >/dev/null 2>&1; then
        paplay "/usr/share/sounds/freedesktop/stereo/${sound}.oga" 2>/dev/null &
    fi
}

# Estado previo y control de alertas
last_ac_state=$(get_ac_state)
warned_low=0
warned_crit=0
warned_danger=0
last_danger_cap=-1
last_danger_time=0
last_crit_time=0

check_power_and_battery() {
    local ac_state
    local bat_status
    local cap
    local now

    ac_state=$(get_ac_state)
    bat_status=$(get_battery_status)
    cap=$(get_battery_capacity)
    now=$(date +%s)

    local cap_str=""
    if [ -n "$cap" ]; then
        cap_str=" (${cap}%)"
    fi

    # 1. Detección de conexión / desconexión del cable de corriente
    if [ "$ac_state" != "$last_ac_state" ]; then
        if [ "$ac_state" = "1" ]; then
            notify-send -e -h string:x-canonical-private-synchronous:power-status \
                -u low -i battery-charging "Cargador Conectado" "Conectado a corriente${cap_str} 󰂄"
            
            # Si existía una alerta crítica de batería, se reemplaza por confirmación de carga
            if [ "$warned_crit" -eq 1 ] || [ "$warned_danger" -eq 1 ]; then
                notify-send -e -h string:x-canonical-private-synchronous:battery-alert \
                    -u low -i battery-charging "Cargando Batería" "Cargador conectado correctamente (${cap}%). El equipo ya no se apagará."
            fi
            play_sound "power-plug"

            # Reiniciar banderas de advertencia
            warned_low=0
            warned_crit=0
            warned_danger=0
            last_danger_cap=-1
        else
            notify-send -e -h string:x-canonical-private-synchronous:power-status \
                -u normal -i battery "Cargador Desconectado" "Desconectado de corriente${cap_str} 󰁹"
            play_sound "power-unplug"

            # Resetear para revaluar de inmediato en batería
            warned_low=0
            warned_crit=0
            warned_danger=0
            last_danger_cap=-1
        fi
        last_ac_state="$ac_state"
    fi

    # 2. Monitoreo del nivel de batería mientras funciona sin corriente o descargando
    if [ "$ac_state" = "0" ] || [ "$bat_status" = "Discharging" ]; then
        if [ -n "$cap" ] && [ "$cap" -ge 0 ] 2>/dev/null; then
            if [ "$cap" -le "$DANGER_BAT_THRESHOLD" ]; then
                # Nivel de Apagado Inminente (<= 5%)
                # Notificar inmediatamente, en cada bajada de porcentaje o cada 45 segundos
                if [ "$warned_danger" -eq 0 ] || [ "$cap" -ne "$last_danger_cap" ] || [ $((now - last_danger_time)) -ge 45 ]; then
                    notify-send -h string:x-canonical-private-synchronous:battery-alert \
                        -u critical -i battery-empty \
                        "🚨 ¡BATERÍA AL ${cap}%: APAGADO INMINENTE! 🚨" \
                        "La batería está a punto de agotarse.\nEl equipo se suspenderá o apagará en cualquier momento.\n\n¡CONECTA EL CARGADOR DE INMEDIATO!"
                    play_sound "dialog-error"
                    warned_danger=1
                    last_danger_cap="$cap"
                    last_danger_time="$now"
                fi
            elif [ "$cap" -le "$CRIT_BAT_THRESHOLD" ]; then
                # Nivel Crítico (6% - 10%)
                # Notificar una vez o recordar cada 3 minutos
                if [ "$warned_crit" -eq 0 ] || [ $((now - last_crit_time)) -ge 180 ]; then
                    notify-send -h string:x-canonical-private-synchronous:battery-alert \
                        -u critical -i battery-caution \
                        "⚠️ Batería Muy Baja (${cap}%)" \
                        "Queda muy poca carga. Por favor conecta el cargador para no perder tu trabajo."
                    play_sound "dialog-warning"
                    warned_crit=1
                    last_crit_time="$now"
                fi
            elif [ "$cap" -le "$LOW_BAT_THRESHOLD" ]; then
                # Advertencia Preventiva de Batería Baja (11% - 20%)
                if [ "$warned_low" -eq 0 ]; then
                    notify-send -h string:x-canonical-private-synchronous:battery-alert \
                        -u normal -i battery-caution \
                        "Batería Baja (${cap}%)" \
                        "Nivel de batería reducido. Considera conectar el cargador pronto."
                    play_sound "window-attention"
                    warned_low=1
                fi
            else
                # Recuperado por encima de 20%
                warned_low=0
                warned_crit=0
                warned_danger=0
                last_danger_cap=-1
            fi
        fi
    else
        # Si está cargando y supera el 25%, dejar listos los disparadores para la próxima descarga
        if [ -n "$cap" ] && [ "$cap" -gt 25 ] 2>/dev/null; then
            warned_low=0
            warned_crit=0
            warned_danger=0
            last_danger_cap=-1
        fi
    fi
}

# Monitoreo continuo cada 2.5 segundos (respuesta rápida ante desenchufe y bajo consumo de CPU)
while true; do
    check_power_and_battery
    sleep 2.5
done
