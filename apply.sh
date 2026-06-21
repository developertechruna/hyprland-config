#!/usr/bin/env bash
# Script para aplicar las configuraciones locales al directorio del usuario y recargar Waybar

echo "Sincronizando configuraciones con ~/.config..."
mkdir -p ~/.config

# Copiar recursivamente
cp -rv config/* ~/.config/

# Asegurar que los scripts tengan permisos de ejecución en el destino
chmod +x ~/.config/rofi/favorites.sh
chmod +x ~/.config/rofi/confirm.sh
chmod +x ~/.config/hypr/toggle_mic.sh

echo "Reiniciando Waybar para aplicar los cambios..."
# Matar cualquier proceso de Waybar corriendo de forma manual o huérfana para evitar duplicados
if pgrep -x "waybar" > /dev/null; then
    killall waybar
    sleep 0.5
fi

if systemctl --user list-unit-files | grep -q "waybar.service"; then
    echo "Servicio de systemd detectado para Waybar. Reiniciando/Iniciando vía systemctl..."
    systemctl --user restart waybar.service
else
    echo "Reiniciando Waybar manualmente..."
    # Iniciar waybar desacoplado usando setsid para que no muera con el terminal
    setsid waybar > /dev/null 2>&1 &
fi

# Recargar Mako para aplicar los cambios de estilo en las notificaciones
if pgrep -x "mako" > /dev/null; then
    echo "Recargando Mako para aplicar el nuevo tema..."
    makoctl reload
fi

echo "Sincronización y reinicio de Waybar/Mako completados con éxito."

