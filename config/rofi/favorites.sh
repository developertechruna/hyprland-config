#!/usr/bin/env bash
# Script para lanzar un menú que combina aplicaciones favoritas al inicio y el resto de apps del sistema

# 1. Definir los favoritos fijos al inicio y sus comandos correspondientes
declare -A favorites
favorites=(
  ["Firefox"]="firefox"
  ["Brave"]="brave --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-webrtc-pipewire-capturer"
  ["Antigravity IDE"]="antigravity-ide"
  ["Eclipse"]="~/.local/bin/eclipse"
  ["Btop"]="xfce4-terminal -e btop"
  ["Terminal"]="xfce4-terminal"
  ["Thunar"]="thunar"
  ["Kill Window (xkill)"]="hyprctl kill"
)

# Diccionario para almacenar la relación Nombre de pantalla -> Comando
declare -A all_apps

# Añadir favoritos primero con un prefijo de estrella para que resalten y se mantenga el orden
fav_list=""
for name in "Firefox" "Brave" "Antigravity IDE" "Eclipse" "Btop" "Terminal" "Thunar" "Kill Window (xkill)"; do
    display_name="  $name"
    all_apps["$display_name"]="${favorites[$name]}"
    fav_list+="$display_name"$'\n'
done

# 2. Leer el resto de aplicaciones del sistema desde archivos .desktop
# Directorios de búsqueda de archivos desktop estándar
files=()
for dir in "/usr/share/applications" "$HOME/.local/share/applications"; do
    [ -d "$dir" ] || continue
    shopt -s nullglob
    for file in "$dir"/*.desktop; do
        files+=("$file")
    done
    shopt -u nullglob
done

if [ ${#files[@]} -gt 0 ]; then
    while IFS=$'\t' read -r name exec_cmd; do
        display_name="  $name"
        # Si la aplicación no está ya en favoritos ni se ha agregado, la añadimos
        if [ -z "${all_apps["$display_name"]}" ] && [ -z "${favorites["$name"]}" ]; then
            all_apps["$display_name"]="$exec_cmd"
        fi
    done < <(awk -F= '
        FILENAME != last_file {
            if (last_file != "" && !nodisplay && name != "" && exec_cmd != "") {
                gsub(/%[fFuiUkKvV]/, "", exec_cmd)
                gsub(/[[:space:]]+$/, "", exec_cmd)
                print name "\t" exec_cmd
            }
            name = ""
            exec_cmd = ""
            nodisplay = 0
            in_entry = 0
            last_file = FILENAME
        }
        /^\[Desktop Entry\]/ {
            in_entry = 1
        }
        /^\[/ && !/^\[Desktop Entry\]/ {
            in_entry = 0
        }
        in_entry && $1 == "NoDisplay" && $2 == "true" {
            nodisplay = 1
        }
        in_entry && $1 == "Name" && name == "" {
            name = substr($0, 6)
        }
        in_entry && $1 == "Exec" && exec_cmd == "" {
            exec_cmd = substr($0, 6)
        }
        END {
            if (!nodisplay && name != "" && exec_cmd != "") {
                gsub(/%[fFuiUkKvV]/, "", exec_cmd)
                gsub(/[[:space:]]+$/, "", exec_cmd)
                print name "\t" exec_cmd
            }
        }
    ' "${files[@]}")
fi


# Construir la lista de las aplicaciones normales para ordenarlas
rest_list=""
for display_name in "${!all_apps[@]}"; do
    if [[ "$display_name" != "⭐"* ]]; then
        rest_list+="$display_name"$'\n'
    fi
done

# Ordenar las aplicaciones del sistema alfabéticamente (ignorando mayúsculas)
sorted_rest=$(echo -n "$rest_list" | sort -f)

# 3. Definir y añadir opciones de energía/sistema al final
declare -A power_ops
power_ops=(
  ["  Bloquear Pantalla"]="hyprlock"
  ["  Reiniciar Sistema"]="systemctl reboot"
  ["  Apagar Sistema"]="systemctl poweroff"
)

power_list=""
for op in "  Bloquear Pantalla" "  Reiniciar Sistema" "  Apagar Sistema"; do
    all_apps["$op"]="${power_ops[$op]}"
    power_list+="$op"$'\n'
done

# Concatenar favoritos, la lista ordenada del sistema y las opciones de energía
full_list="${fav_list}${sorted_rest}"$'\n'"${power_list}"


# Mostrar el menú en Rofi
choice=$(echo -n "$full_list" | rofi -dmenu -i -p "🚀 Ejecutar")

# Si el usuario seleccionó una opción, ejecutar su comando correspondiente en segundo plano
if [ -n "$choice" ]; then
    cmd="${all_apps[$choice]}"
    if [ -n "$cmd" ]; then
        eval "$cmd &"
    fi
fi
