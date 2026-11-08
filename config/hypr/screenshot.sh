#!/usr/bin/env bash
# ==============================================================================
# Script unificado de captura de pantalla para Hyprland / Wayland
# Soporta recorte interactivo, anotación gráfica con Swappy o Satty,
# y captura rápida directa al portapapeles.
# ==============================================================================

MODE="${1:-edit}"

# Estilo visual de la selección (Catppuccin Mocha / Sapphire)
SLURP_ARGS="-d -c 89b4faff -b 1e1e2e99 -s 89b4fa33 -w 2"

mkdir -p "$HOME/Pictures/Screenshots" 2>/dev/null || true

case "$MODE" in
    edit)
        # Seleccionar región interactiva y abrir en editor de anotaciones
        GEOM=$(slurp $SLURP_ARGS)
        [ -z "$GEOM" ] && exit 0

        if command -v satty >/dev/null 2>&1; then
            grim -g "$GEOM" - | satty --filename - --fullscreen
        elif command -v swappy >/dev/null 2>&1; then
            grim -g "$GEOM" - | swappy -f -
        else
            grim -g "$GEOM" - | wl-copy -t image/png
            notify-send "Captura de pantalla" "Región copiada al portapapeles" -i camera-photo -t 2500
        fi
        ;;

    copy|area)
        # Seleccionar región y copiar inmediatamente al portapapeles
        GEOM=$(slurp $SLURP_ARGS)
        [ -z "$GEOM" ] && exit 0
        grim -g "$GEOM" - | wl-copy -t image/png
        notify-send "Captura de región" "Imagen copiada al portapapeles" -i camera-photo -t 2000
        ;;

    window)
        # Capturar la ventana enfocada actualmente
        ACTIVE_WIN=$(hyprctl activewindow -j 2>/dev/null)
        if [ -n "$ACTIVE_WIN" ] && [ "$ACTIVE_WIN" != "{}" ]; then
            AT=$(echo "$ACTIVE_WIN" | jq -r '.at | "\(.[0]),\(.[1])"')
            SIZE=$(echo "$ACTIVE_WIN" | jq -r '.size | "\(.[0])x\(.[1])"')
            GEOM="${AT} ${SIZE}"
            grim -g "$GEOM" - | wl-copy -t image/png
            notify-send "Captura de ventana" "Ventana copiada al portapapeles" -i camera-photo -t 2000
        else
            GEOM=$(slurp $SLURP_ARGS)
            [ -z "$GEOM" ] && exit 0
            grim -g "$GEOM" - | wl-copy -t image/png
            notify-send "Captura de pantalla" "Copiada al portapapeles" -i camera-photo -t 2000
        fi
        ;;

    full)
        # Capturar toda la pantalla directamente al portapapeles
        grim - | wl-copy -t image/png
        notify-send "Pantalla completa" "Captura copiada al portapapeles" -i camera-photo -t 2000
        ;;

    *)
        echo "Uso: $0 [edit|copy|window|full]"
        exit 1
        ;;
esac

