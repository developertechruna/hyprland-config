#!/usr/bin/env bash
# ==============================================================================
# Script para gestionar la VPN en Waybar usando Rofi y nmcli (Solo icono)
# ==============================================================================

VPN_STATE_FILE="/tmp/vpn_state"

# Función para obtener la VPN activa en NetworkManager
get_active_vpn() {
    nmcli -t -f name,type connection show --active | grep -E ':(vpn|wireguard)' | cut -d: -f1 | head -n 1
}

# Función para conectar VPN directamente con credenciales guardadas
activate_vpn() {
    local vpn="$1"
    echo "connecting" > "$VPN_STATE_FILE"
    trap 'rm -f "$VPN_STATE_FILE"; pkill -RTMIN+8 waybar 2>/dev/null || true' EXIT INT TERM
    pkill -RTMIN+8 waybar 2>/dev/null || true

    notify-send "VPN" "Estableciendo conexión a $vpn..." -i network-vpn-symbolic -t 3000

    if nmcli connection up "$vpn"; then
        rm -f "$VPN_STATE_FILE"
        notify-send "VPN" "Conectado exitosamente a $vpn" -i network-vpn-symbolic -t 4000
        pkill -RTMIN+8 waybar 2>/dev/null || true
        return 0
    else
        rm -f "$VPN_STATE_FILE"
        notify-send "VPN" "Error al conectar a $vpn" -u critical -i dialog-error -t 5000
        pkill -RTMIN+8 waybar 2>/dev/null || true
        return 1
    fi
}

# Si se ejecuta con el argumento "menu", muestra la selección en Rofi
if [ "$1" = "menu" ]; then
    active_vpn=$(get_active_vpn)
    
    # Obtener la lista de todas las conexiones VPN configuradas
    vpns=$(nmcli -g name,type connection show | grep -E ':(vpn|wireguard)' | cut -d: -f1)
    
    if [ -z "$vpns" ]; then
        rofi -e "No hay conexiones VPN configuradas en NetworkManager."
        exit 0
    fi
    
    # Generar las opciones para el dmenu de Rofi
    rofi_options=""
    while read -r vpn; do
        [ -z "$vpn" ] && continue
        if [ "$vpn" = "$active_vpn" ]; then
            rofi_options+="  Desconectar $vpn"$'\n'
        else
            rofi_options+="  Conectar $vpn"$'\n'
        fi
    done <<< "$vpns"
    
    # Mostrar menú de Rofi
    choice=$(echo -n "$rofi_options" | rofi -dmenu -i -p "  Seleccionar VPN")
    
    # Procesar selección
    if [ -n "$choice" ]; then
        vpn_name=$(echo "$choice" | sed -e 's/  Desconectar //g' -e 's/  Conectar //g')
        if echo "$choice" | grep -q "Desconectar"; then
            nmcli connection down "$vpn_name"
            notify-send "VPN" "Desconectado de $vpn_name" -i network-vpn-symbolic -t 3000
            pkill -RTMIN+8 waybar 2>/dev/null || true
        else
            activate_vpn "$vpn_name"
        fi
    fi
    exit 0
fi

# Comportamiento por defecto: devolver solo el icono en formato JSON para Waybar
if [ -f "$VPN_STATE_FILE" ]; then
    echo '{"text": "", "tooltip": "VPN: Estableciendo conexión...", "class": "connecting"}'
    exit 0
fi

active_vpn=$(get_active_vpn)

if [ -n "$active_vpn" ]; then
    # Candado cerrado activo cuando la VPN está conectada
    echo "{\"text\": \"\", \"tooltip\": \"VPN: Conectada a $active_vpn\n\nClic izquierdo: Menú de conexiones\", \"class\": \"connected\"}"
else
    # Candado abierto cuando la VPN está desconectada
    echo "{\"text\": \"\", \"tooltip\": \"VPN: Desconectada\n\nClic izquierdo: Conectar VPN\", \"class\": \"disconnected\"}"
fi
