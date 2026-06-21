#!/usr/bin/env bash
# Script de confirmación con Rofi para acciones críticas (Apagar, Reiniciar)

ACTION=$1
if [ -z "$ACTION" ]; then
    echo "Uso: $0 [reboot|poweroff]"
    exit 1
fi

case "$ACTION" in
    reboot)
        TITLE="🔄 ¿Reiniciar el sistema?"
        CMD="systemctl reboot"
        YES_MSG="✔️ Sí, reiniciar"
        ;;
    poweroff)
        TITLE="🛑 ¿Apagar el sistema?"
        CMD="systemctl poweroff"
        YES_MSG="✔️ Sí, apagar"
        ;;
    *)
        echo "Acción no válida: $ACTION"
        exit 1
        ;;
esac

NO_MSG="❌ No, cancelar"

# Mostrar el menú en Rofi con un tema súper compacto
CHOICE=$(echo -e "$YES_MSG\n$NO_MSG" | rofi -dmenu -i -p "$TITLE" -theme-str '
    window {
        width: 300px;
        height: 130px;
        border: 2px;
        border-color: #cba6f7;
        border-radius: 8px;
    }
    inputbar {
        enabled: false;
    }
    listview {
        lines: 2;
        scrollbar: false;
    }
    element {
        padding: 8px;
    }
')

if [ "$CHOICE" = "$YES_MSG" ]; then
    $CMD
fi
