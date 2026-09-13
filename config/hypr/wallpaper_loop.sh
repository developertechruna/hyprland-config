#!/usr/bin/env bash
# Script para rotación automática de fondo de pantalla cada 5 minutos en Hyprland usando awww

WALLPAPER_DIR="${1:-$HOME/Documents/Imágenes/wallpaper}"
INTERVAL=300

# Asegurar que el demonio awww-daemon esté ejecutándose
if ! pgrep -x "awww-daemon" > /dev/null; then
    echo "Iniciando awww-daemon..."
    awww-daemon > /dev/null 2>&1 &
    sleep 1
fi

while true; do
    if [ -d "$WALLPAPER_DIR" ]; then
        # Buscar imágenes compatibles (jpg, jpeg, png, webp, gif)
        IMAGE=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) | shuf -n 1)
        
        if [ -n "$IMAGE" ]; then
            echo "Cambiando fondo de pantalla a: $IMAGE"
            awww img "$IMAGE" --transition-type random --transition-duration 2 > /dev/null 2>&1
        else
            echo "Advertencia: No se encontraron imágenes en $WALLPAPER_DIR"
        fi
    else
        echo "Error: El directorio $WALLPAPER_DIR no existe."
    fi
    
    sleep "$INTERVAL"
done
