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
chmod +x ~/.config/hypr/launch_docks.py
chmod +x ~/.config/hypr/toggle_dock.py
chmod +x ~/.config/hypr/wallpaper_loop.sh
chmod +x ~/.config/hypr/set_gtk.sh 2>/dev/null || true

# Copiar .gtkrc-2.0 al directorio raíz de usuario para compatibilidad GTK 2
if [ -f "config/gtk-2.0/.gtkrc-2.0" ]; then
    cp -v config/gtk-2.0/.gtkrc-2.0 ~/.gtkrc-2.0
fi

# Sincronizar lanzadores de aplicaciones y manejadores de URL en ~/.local/share/applications
if [ -d "applications" ]; then
    echo "Sincronizando lanzadores de aplicaciones en ~/.local/share/applications..."
    mkdir -p ~/.local/share/applications
    cp -v applications/*.desktop ~/.local/share/applications/
fi

# Sincronizar fuentes personalizadas en ~/.local/share/fonts
if [ -d "fonts" ]; then
    echo "Sincronizando fuentes en ~/.local/share/fonts..."
    mkdir -p ~/.local/share/fonts
    cp -v fonts/*.ttf ~/.local/share/fonts/ 2>/dev/null || true
    if command -v fc-cache > /dev/null 2>&1; then
        echo "Actualizando caché de fuentes del sistema (fc-cache)..."
        fc-cache -f ~/.local/share/fonts/ > /dev/null 2>&1 || true
    fi
fi

# Respaldar y sincronizar configuración de Zsh
if [ -f "config/zsh/.zshrc" ]; then
    if [ -f "$HOME/.zshrc" ] && [ ! -f "$HOME/.zshrc.bak" ]; then
        echo "Creando respaldo de ~/.zshrc en ~/.zshrc.bak..."
        cp -v "$HOME/.zshrc" "$HOME/.zshrc.bak"
    fi
    echo "Instalando configuración de Zsh en ~/.zshrc..."
    cp -v config/zsh/.zshrc ~/.zshrc
fi

echo "Aplicando configuración de fuentes y temas GTK vía GSettings..."
if [ -f "$HOME/.config/hypr/set_gtk.sh" ]; then
    bash "$HOME/.config/hypr/set_gtk.sh"
fi

echo "Reiniciando rotación automática de fondos de pantalla..."
pkill -f "wallpaper_loop.sh" > /dev/null 2>&1
setsid bash ~/.config/hypr/wallpaper_loop.sh > /dev/null 2>&1 &

echo "Reiniciando Waybar para aplicar los cambios..."
# Si Waybar está corriendo activamente como servicio de systemd
if systemctl --user is-active --quiet waybar.service; then
    echo "Servicio de systemd activo para Waybar. Reiniciando vía systemctl..."
    systemctl --user restart waybar.service || {
        echo "Fallo al reiniciar servicio systemd. Iniciando Waybar manualmente..."
        setsid waybar > /dev/null 2>&1 &
    }
else
    # Matar cualquier proceso de Waybar corriendo de forma manual o huérfana para evitar duplicados
    if pgrep -x "waybar" > /dev/null; then
        killall waybar
        sleep 0.5
    fi
    echo "Iniciando Waybar manualmente..."
    # Iniciar waybar desacoplado usando setsid para que no muera con el terminal
    setsid waybar > /dev/null 2>&1 &
fi

# Recargar Mako para aplicar los cambios de estilo en las notificaciones
if pgrep -x "mako" > /dev/null; then
    echo "Recargando Mako para aplicar el nuevo tema..."
    makoctl reload
fi

# Reiniciar hypridle para aplicar los tiempos de inactividad y bloqueo actualizados
if pgrep -x "hypridle" > /dev/null; then
    killall hypridle
    sleep 0.5
fi
if command -v hypridle > /dev/null 2>&1; then
    echo "Reiniciando gestor de inactividad y bloqueo (hypridle)..."
    setsid hypridle > /dev/null 2>&1 &
fi

# Actualizar base de datos de aplicaciones y manejadores de protocolos MIME
if command -v update-desktop-database > /dev/null 2>&1; then
    echo "Actualizando base de datos de aplicaciones y esquemas URL (MIME)..."
    update-desktop-database ~/.local/share/applications 2>/dev/null || true
fi

echo "Sincronización de GTK (fuente 8pt), Waybar, Mako y MIME completados con éxito."



