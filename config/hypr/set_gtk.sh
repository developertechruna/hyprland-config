#!/usr/bin/env bash
# Script para sincronizar las configuraciones de GTK y GNOME Interface en Hyprland / Wayland

FONT="SauceCodePro Nerd Font 8"
FONT_BOLD="SauceCodePro Nerd Font Bold 8"
THEME="catppuccin-mocha-lavender-standard+default"
ICONS="Tela-circle-dark"
CURSOR="catppuccin-mocha-lavender-cursors"
CURSOR_SIZE=24

# Sincronización mediante GSettings para Wayland / XDG Portals / GTK 3 & 4
if command -v gsettings > /dev/null 2>&1; then
    # Fuentes tamaño 9
    gsettings set org.gnome.desktop.interface font-name "$FONT"
    gsettings set org.gnome.desktop.interface document-font-name "$FONT"
    gsettings set org.gnome.desktop.interface monospace-font-name "$FONT"
    gsettings set org.gnome.desktop.wm.preferences titlebar-font "$FONT_BOLD"

    # Temas e Iconos
    gsettings set org.gnome.desktop.interface gtk-theme "$THEME"
    gsettings set org.gnome.desktop.wm.preferences theme "$THEME"
    gsettings set org.gnome.desktop.interface icon-theme "$ICONS"
    gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR"
    gsettings set org.gnome.desktop.interface cursor-size "$CURSOR_SIZE"

    # Modo oscuro y renderizado de tipografía
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'
    gsettings set org.gnome.desktop.interface font-hinting 'slight'
fi
