#!/usr/bin/env bash
# ==============================================================================
# Script de instalación del tema LightDM GTK Greeter (Catppuccin Mocha Sapphire)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WALLPAPER_SRC="${1:-}"

if [ "$EUID" -ne 0 ]; then
    echo "Por favor ejecuta este script con sudo: sudo bash $0 [ruta_opcional_wallpaper]"
    exit 1
fi

echo "=== Configurando LightDM GTK Greeter con tema Catppuccin Mocha Sapphire ==="

# 1. Respaldar configuración previa si existe
if [ -f "/etc/lightdm/lightdm-gtk-greeter.conf" ] && [ ! -f "/etc/lightdm/lightdm-gtk-greeter.conf.bak" ]; then
    echo "Respaldando /etc/lightdm/lightdm-gtk-greeter.conf -> .bak..."
    cp /etc/lightdm/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf.bak
fi

# 2. Copiar archivo de configuración principal
echo "Instalando /etc/lightdm/lightdm-gtk-greeter.conf..."
cp "$SCRIPT_DIR/lightdm-gtk-greeter.conf" /etc/lightdm/lightdm-gtk-greeter.conf
chmod 644 /etc/lightdm/lightdm-gtk-greeter.conf

# 3. Instalar estilos GTK3 personalizados
echo "Instalando estilos GTK3 en /etc/gtk-3.0/gtk.css..."
mkdir -p /etc/gtk-3.0
if [ -f "/etc/gtk-3.0/gtk.css" ]; then
    # Concatenar o respaldar
    cp /etc/gtk-3.0/gtk.css /etc/gtk-3.0/gtk.css.bak
fi
cp "$SCRIPT_DIR/gtk.css" /etc/gtk-3.0/gtk.css
chmod 644 /etc/gtk-3.0/gtk.css

# 4. Asegurar directorio de fondos y permisos accesibles para LightDM
mkdir -p /usr/share/backgrounds
chmod 755 /usr/share/backgrounds

if [ -n "$WALLPAPER_SRC" ] && [ -f "$WALLPAPER_SRC" ]; then
    echo "Copiando wallpaper especificado: $WALLPAPER_SRC..."
    cp "$WALLPAPER_SRC" /usr/share/backgrounds/lightdm-wallpaper.jpg
    chmod 644 /usr/share/backgrounds/lightdm-wallpaper.jpg
elif [ ! -f "/usr/share/backgrounds/lightdm-wallpaper.jpg" ]; then
    # Buscar algún wallpaper de la carpeta del usuario si existe
    USER_WALL="$(find /home/johnny/Documents/Imágenes/wallpaper/ -type f \( -iname "*.jpg" -o -iname "*.png" \) 2>/dev/null | head -n 1 || true)"
    if [ -n "$USER_WALL" ] && [ -f "$USER_WALL" ]; then
        echo "Copiando wallpaper por defecto desde $USER_WALL..."
        cp "$USER_WALL" /usr/share/backgrounds/lightdm-wallpaper.jpg
        chmod 644 /usr/share/backgrounds/lightdm-wallpaper.jpg
    fi
fi

# 5. Opcional: Crear enlace simbólico de WhiteSur-dark si se desea en /usr/share/icons
if [ -d "/home/johnny/.local/share/icons/WhiteSur-dark" ] && [ ! -d "/usr/share/icons/WhiteSur-dark" ]; then
    echo "Enlazando WhiteSur-dark a /usr/share/icons para acceso global de LightDM..."
    ln -s /home/johnny/.local/share/icons/WhiteSur-dark /usr/share/icons/WhiteSur-dark || true
fi

echo ""
echo "¡Tema instalado exitosamente!"
echo "Puedes probar la apariencia sin cerrar sesión ejecutando en terminal (modo prueba):"
echo "  lightdm-gtk-greeter-settings (si está instalado) o iniciando una subsesión Xephyr"
