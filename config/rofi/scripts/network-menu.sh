#!/usr/bin/env bash
# ==========================================
# Menú de Red y VPN interactivo con Rofi y nmcli
# Ubicación original destino: ~/.config/rofi/scripts/network-menu.sh
# ==========================================

# 1. Obtener estado de VPNs
active_vpns=$(nmcli -t -f name,type connection show --active | grep -E ':(vpn|wireguard)' | cut -d: -f1)
all_vpns=$(nmcli -g name,type connection show | grep -E ':(vpn|wireguard)' | cut -d: -f1)

# 2. Obtener estado de red cableada (Ethernet)
active_eth=$(nmcli -t -f name,type,device connection show --active | grep -E ':(802-3-ethernet|ethernet):' | head -n 1)
eth_info=""
if [ -n "$active_eth" ]; then
    eth_name=$(echo "$active_eth" | cut -d: -f1)
    eth_dev=$(echo "$active_eth" | cut -d: -f3)
    eth_ip=$(ip -4 addr show "$eth_dev" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)
    eth_info="󰈀  Ethernet: $eth_name ($eth_ip)"
fi

# 3. Estado de Wi-Fi
wifi_enabled=$(nmcli radio wifi)
active_wifi=$(nmcli -t -f name,type connection show --active | grep ':802-11-wireless' | cut -d: -f1 | head -n 1)

options=""

# --- SECCIÓN RED ACTIVA ---
if [ -n "$eth_info" ]; then
    options+="$eth_info"$'\n'
fi
if [ -n "$active_wifi" ]; then
    options+="󰤨  Wi-Fi Conectado: $active_wifi"$'\n'
fi

# --- SECCIÓN VPN (DESTACADA) ---
if [ -n "$all_vpns" ]; then
    while read -r vpn; do
        [ -z "$vpn" ] && continue
        if echo "$active_vpns" | grep -qw "$vpn"; then
            options+="  Desconectar VPN: $vpn"$'\n'
        else
            options+="  Conectar VPN: $vpn"$'\n'
        fi
    done <<< "$all_vpns"
fi

# --- SECCIÓN REDES WI-FI DISPONIBLES ---
if [ "$wifi_enabled" = "enabled" ]; then
    seen_ssids=" "
    count=0
    while IFS=: read -r in_use signal ssid; do
        [ -z "$ssid" ] && continue
        [ "$count" -ge 8 ] && break
        
        # Evitar duplicados
        if [[ "$seen_ssids" == *" $ssid "* ]]; then
            continue
        fi
        seen_ssids+="$ssid "
        ((count++))

        # Icono según intensidad de señal
        if [ "$signal" -ge 75 ]; then
            icon="󰤨"
        elif [ "$signal" -ge 50 ]; then
            icon="󰤥"
        elif [ "$signal" -ge 25 ]; then
            icon="󰤢"
        else
            icon="󰤟"
        fi

        if [ "$in_use" = "*" ]; then
            continue # Ya mostrado en sección activa
        fi
        options+="$icon  Wi-Fi: $ssid"$'\n'
    done < <(nmcli -t -f IN-USE,SIGNAL,SSID device wifi list 2>/dev/null)
    
    options+="󰤮  Desactivar Wi-Fi"$'\n'
else
    options+="󰤨  Activar Wi-Fi"$'\n'
fi

# --- HERRAMIENTAS ---
options+="  Configuración avanzada (nm-connection-editor)"$'\n'
options+="  Consola de red (nmtui)"

# Lanzar Rofi
chosen=$(echo -n "$options" | rofi -dmenu -i -p "󰖩  Red y VPN" -theme-str 'entry { placeholder: "Buscar red o acción..."; }')
[ -z "$chosen" ] && exit 0

# Procesar la opción elegida
case "$chosen" in
    *"Desconectar VPN: "*)
        vpn_name=$(echo "$chosen" | sed 's/.*Desconectar VPN: //')
        nmcli connection down "$vpn_name"
        notify-send "VPN" "Desconectado de $vpn_name" -i network-vpn-symbolic
        pkill -RTMIN+8 waybar 2>/dev/null || true
        ;;
    *"Conectar VPN: "*)
        vpn_name=$(echo "$chosen" | sed 's/.*Conectar VPN: //')
        notify-send "VPN" "Conectando a $vpn_name..." -i network-vpn-symbolic
        if nmcli connection up "$vpn_name"; then
            notify-send "VPN" "Conectado exitosamente a $vpn_name" -i network-vpn-symbolic
        else
            notify-send "VPN" "Error al conectar a $vpn_name" -u critical -i dialog-error
        fi
        pkill -RTMIN+8 waybar 2>/dev/null || true
        ;;
    *"Wi-Fi Conectado: "*)
        nmcli connection down "$active_wifi"
        ;;
    *"Wi-Fi: "*)
        ssid=$(echo "$chosen" | sed 's/.*Wi-Fi: //')
        # Si ya existe conexión guardada
        if nmcli -g name connection show | grep -Fxq "$ssid"; then
            notify-send "Wi-Fi" "Conectando a $ssid..." -i network-wireless-symbolic
            if nmcli connection up "$ssid"; then
                notify-send "Wi-Fi" "Conectado exitosamente a $ssid" -i network-wireless-symbolic
            else
                notify-send "Wi-Fi" "Error al conectar a $ssid" -u critical -i dialog-error
            fi
        else
            # Pedir contraseña vía Rofi
            wifi_pass=$(echo "" | rofi -dmenu \
                -password \
                -p "󰌆 Contraseña" \
                -mesg "Conectando a la red Wi-Fi: <b>$ssid</b>" \
                -theme-str 'mainbox { children: [ message, inputbar ]; }' \
                -theme-str 'listview { enabled: false; }' \
                -theme-str 'entry { placeholder: "Introduce la contraseña..."; }')
            if [ -n "$wifi_pass" ]; then
                notify-send "Wi-Fi" "Conectando a $ssid..." -i network-wireless-symbolic
                if nmcli dev wifi connect "$ssid" password "$wifi_pass"; then
                    notify-send "Wi-Fi" "Conectado exitosamente a $ssid" -i network-wireless-symbolic
                else
                    notify-send "Wi-Fi" "Error al conectar a $ssid. Contraseña inválida." -u critical -i dialog-error
                fi
            fi
        fi
        ;;
    *"Desactivar Wi-Fi"*)
        nmcli radio wifi off
        ;;
    *"Activar Wi-Fi"*)
        nmcli radio wifi on
        ;;
    *"Configuración avanzada"*)
        nm-connection-editor &
        ;;
    *"Consola de red"*)
        kitty --class floating_terminal -T "Network Manager" -e nmtui
        ;;
esac
