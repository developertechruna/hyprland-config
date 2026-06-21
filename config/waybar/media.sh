#!/usr/bin/env bash
# Script para mostrar el estado del reproductor de medios en Waybar
# Ubicación original destino: ~/.config/waybar/media.sh

# Verificar si playerctl está instalado
if ! command -v playerctl &> /dev/null; then
    echo '{"text": "Instalar playerctl", "tooltip": "No se encontró la herramienta playerctl", "class": "error"}'
    exit 0
fi

# Obtener el estado del reproductor
player_status=$(playerctl status 2>/dev/null)

if [ -z "$player_status" ]; then
    # Ocultar el módulo si no hay ningún reproductor activo
    echo ""
    exit 0
fi

# Obtener metadatos básicos
artist=$(playerctl metadata artist 2>/dev/null)
title=$(playerctl metadata title 2>/dev/null)
album=$(playerctl metadata album 2>/dev/null)

# Escapar comillas dobles para que el JSON sea válido
artist=$(echo "$artist" | sed 's/"/\\"/g')
title=$(echo "$title" | sed 's/"/\\"/g')
album=$(echo "$album" | sed 's/"/\\"/g')

# Definir el icono y la clase según el estado
if [ "$player_status" = "Playing" ]; then
    icon="" # Icono de música de FontAwesome (nota musical)
    class="playing"
elif [ "$player_status" = "Paused" ]; then
    icon="" # Icono de pausa
    class="paused"
else
    icon="" # Icono de stop
    class="stopped"
fi

# Formatear el texto de salida
if [ -n "$artist" ] && [ -n "$title" ]; then
    display_text="$icon  $artist - $title"
elif [ -n "$title" ]; then
    display_text="$icon  $title"
else
    display_text="$icon  Reproduciendo..."
fi

# Limitar la longitud del texto para no deformar la barra
max_length=40
if [ ${#display_text} -gt $max_length ]; then
    display_text="${display_text:0:$((max_length - 3))}..."
fi

# Generar la salida JSON para Waybar
echo "{\"text\": \"$display_text\", \"tooltip\": \"🎵 Título: $title\n👤 Artista: $artist\n💿 Álbum: $album\n\n🖱️ Click: Play/Pause\n🖱️ Scroll Arriba: Siguiente\n🖱️ Scroll Abajo: Anterior\", \"class\": \"$class\"}"
