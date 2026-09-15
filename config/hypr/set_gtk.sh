#!/usr/bin/env bash
# Script para sincronizar las configuraciones de GTK y GNOME Interface en Hyprland / Wayland

FONT="Inter 10"
FONT_BOLD="Inter SemiBold 10"
FONT_MONO="JetBrainsMono Nerd Font 10"
THEME="catppuccin-mocha-sapphire-standard+default"
ICONS="WhiteSur-dark"
CURSOR="catppuccin-mocha-sapphire-cursors"
CURSOR_SIZE=24

# Sincronización mediante GSettings para Wayland / XDG Portals / GTK 3 & 4
if command -v gsettings > /dev/null 2>&1; then
    # Fuentes de interfaz (Inter) y monoespaciada (JetBrains Mono)
    gsettings set org.gnome.desktop.interface font-name "$FONT"
    gsettings set org.gnome.desktop.interface document-font-name "$FONT"
    gsettings set org.gnome.desktop.interface monospace-font-name "$FONT_MONO"
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
