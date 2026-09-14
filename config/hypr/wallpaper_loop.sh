#!/usr/bin/env bash
# Script para rotación automática de fondo de pantalla cada 5 minutos en Hyprland usando awww
# Soporta asignación independiente por pantalla (monitor) si existen múltiples pantallas o carpetas dedicadas.

# Directorio de fondos de pantalla por defecto o mediante argumento
DEFAULT_DIR="$HOME/Documents/Imágenes/wallpaper"
if [ ! -d "$DEFAULT_DIR" ] && [ -d "$HOME/Documentos/Imágenes/wallpaper" ]; then
    DEFAULT_DIR="$HOME/Documentos/Imágenes/wallpaper"
elif [ ! -d "$DEFAULT_DIR" ] && [ -d "$HOME/Pictures/wallpapers" ]; then
    DEFAULT_DIR="$HOME/Pictures/wallpapers"
elif [ ! -d "$DEFAULT_DIR" ] && [ -d "$HOME/Pictures/wallpaper" ]; then
    DEFAULT_DIR="$HOME/Pictures/wallpaper"
fi

WALLPAPER_DIR="${1:-$DEFAULT_DIR}"
INTERVAL="${INTERVAL:-300}"
ONCE=false

# Permitir argumento para ejecución única (ej: wallpaper_loop.sh --once)
if [ "$1" = "--once" ] || [ "$1" = "-1" ] || [ "$1" = "now" ]; then
    ONCE=true
    WALLPAPER_DIR="$DEFAULT_DIR"
elif [ "$2" = "--once" ] || [ "$2" = "-1" ] || [ "$2" = "now" ]; then
    ONCE=true
fi

# Asegurar que el demonio awww-daemon esté ejecutándose
if ! pgrep -x "awww-daemon" > /dev/null; then
    echo "Iniciando awww-daemon..."
    awww-daemon > /dev/null 2>&1 &
    sleep 1
fi

get_monitors() {
    local mons=""
    # Intentar obtener monitores reportados por awww
    mons=$(awww query 2>/dev/null | awk -F: '{print $2}' | tr -d ' ' | grep -v '^$')
    # Si awww aún no los lista, consultar directamente a hyprctl
    if [ -z "$mons" ]; then
        mons=$(hyprctl monitors 2>/dev/null | awk '/^Monitor/{print $2}' | grep -v '^$')
    fi
    echo "$mons"
}

change_wallpapers() {
    if [ ! -d "$WALLPAPER_DIR" ]; then
        echo "Error: El directorio $WALLPAPER_DIR no existe."
        return 1
    fi

    # Obtener monitores conectados
    local monitors
    monitors=$(get_monitors)

    # Buscar imágenes compatibles en el directorio principal
    mapfile -t all_images < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) 2>/dev/null | shuf)
    local total_images=${#all_images[@]}

    if [ "$total_images" -eq 0 ]; then
        echo "Advertencia: No se encontraron imágenes compatibles en $WALLPAPER_DIR"
        return 1
    fi

    if [ -n "$monitors" ]; then
        local idx=0
        for mon in $monitors; do
            local img=""
            local mon_lower="${mon,,}"

            # 1. Comprobar si existe subdirectorio específico para este monitor (ej: eDP-1 o edp-1)
            if [ -d "$WALLPAPER_DIR/$mon" ]; then
                img=$(find "$WALLPAPER_DIR/$mon" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) 2>/dev/null | shuf -n 1)
            elif [ -d "$WALLPAPER_DIR/$mon_lower" ]; then
                img=$(find "$WALLPAPER_DIR/$mon_lower" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) 2>/dev/null | shuf -n 1)
            fi

            # 2. Si no hay carpeta específica o está vacía, asignar una imagen aleatoria sin repetir si es posible
            if [ -z "$img" ]; then
                img="${all_images[$((idx % total_images))]}"
                idx=$((idx + 1))
            fi

            if [ -n "$img" ]; then
                echo "Cambiando fondo para monitor $mon a: $img"
                awww img -o "$mon" "$img" --transition-type random --transition-duration 2 > /dev/null 2>&1
            fi
        done
    else
        # Fallback si no se detectaron monitores específicos
        local fallback_img="${all_images[0]}"
        echo "Cambiando fondo de pantalla global a: $fallback_img"
        awww img "$fallback_img" --transition-type random --transition-duration 2 > /dev/null 2>&1
    fi
}

# Bucle principal o ejecución única
if [ "$ONCE" = true ]; then
    change_wallpapers
    exit 0
fi

while true; do
    change_wallpapers
    sleep "$INTERVAL"
done
