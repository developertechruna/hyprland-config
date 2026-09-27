#!/usr/bin/env bash
# Script para gestionar la VPN en Waybar usando Rofi y nmcli

# Función para obtener la VPN activa en NetworkManager
get_active_vpn() {
    nmcli -t -f name,type connection show --active | grep -E ':(vpn|wireguard)' | cut -d: -f1 | head -n 1
}

# Función para conectar VPN directamente con credenciales guardadas
activate_vpn() {
    local vpn="$1"
    if nmcli connection up "$vpn"; then
        notify-send "VPN" "Conectado exitosamente a $vpn" -i network-vpn-symbolic
        return 0
    else
        notify-send "VPN" "Error al conectar a $vpn" -u critical -i dialog-error
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
            notify-send "VPN" "Desconectado de $vpn_name" -i network-vpn-symbolic
        else
            notify-send "VPN" "Conectando a $vpn_name..." -i network-vpn-symbolic
            activate_vpn "$vpn_name"
        fi
        
        # Enviar señal a Waybar para actualizar el módulo inmediatamente (señal RTMIN+8)
        sleep 1
        pkill -RTMIN+8 waybar 2>/dev/null || true
    fi
    exit 0
fi

# Comportamiento por defecto: devolver el estado de la VPN en formato JSON para Waybar
active_vpn=$(get_active_vpn)

if [ -n "$active_vpn" ]; then
    # Mostrar icono de candado cerrado y nombre de la VPN conectada
    echo "{\"text\": \"  $active_vpn\", \"tooltip\": \"Conectado a: $active_vpn\", \"class\": \"connected\"}"
else
    # Mostrar candado abierto si no hay VPN activa
    echo "{\"text\": \"  VPN\", \"tooltip\": \"VPN Desconectada\", \"class\": \"disconnected\"}"
fi
