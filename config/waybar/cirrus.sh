#!/usr/bin/env bash
# ==============================================================================
# Script dedicado para montar / desmontar Cirrus F3 (Tailscale + CIFS) en Waybar
# ==============================================================================

# Cargar variables de entorno personalizadas si existen
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/desktop/desktop.conf"
if [ -f "$CONFIG_FILE" ]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
fi

CIRRUS_MOUNT="${CIRRUS_MOUNT:-$HOME/Doc Projects/cirrus/F3/NFS}"
CIRRUS_SERVER="${CIRRUS_SERVER:-//10.0.0.10/Publico}"
CIRRUS_CREDS="${CIRRUS_CREDS:-/root/.smb-publico}"
CIRRUS_HOST="${CIRRUS_HOST:-$(echo "$CIRRUS_SERVER" | sed -E 's|^//([^/]+)/.*|\1|')}"
STATE_FILE="/tmp/cirrus_state"

# Función para verificar si Cirrus F3 está montado
is_cirrus_mounted() {
    [ "$(findmnt -T "$CIRRUS_MOUNT" -o FSTYPE -n 2>/dev/null)" = "cifs" ]
}

# Función para montar Cirrus F3
mount_cirrus() {
    if is_cirrus_mounted; then
        notify-send "Cirrus F3" "La carpeta ya se encuentra montada." -i folder-remote
        return 0
    fi

    # Evitar ejecuciones simultáneas si ya está conectando
    if [ -f "$STATE_FILE" ]; then
        notify-send "Cirrus F3" "Ya hay un proceso de conexión en curso..." -i network-transmit-receive
        return 0
    fi

    echo "connecting" > "$STATE_FILE"
    trap 'rm -f "$STATE_FILE"; pkill -RTMIN+9 waybar 2>/dev/null || true' EXIT INT TERM
    pkill -RTMIN+9 waybar 2>/dev/null || true

    notify-send "Cirrus F3" "Conectando a la red y preparando montaje..." -i network-transmit-receive -t 4000

    # 1. Asegurar que el demonio del sistema Tailscale esté corriendo
    if ! systemctl is-active tailscaled.service >/dev/null 2>&1; then
        notify-send "Cirrus F3" "Iniciando servicio de red Tailscale..." -i network-server -t 2500
        systemctl start tailscaled.service 2>/dev/null || pkexec systemctl start tailscaled.service
    fi

    # 2. Conectar a la Tailnet si estaba en estado 'Stopped'
    backend_state=$(tailscale status --json 2>/dev/null | jq -r .BackendState 2>/dev/null)
    if [ "$backend_state" != "Running" ]; then
        tailscale up 2>/dev/null || pkexec tailscale up
    fi

    # 3. Iniciar Trayscale en segundo plano (icono en la bandeja)
    if ! pgrep -f trayscale >/dev/null 2>&1; then
        trayscale --hide-window &
    fi

    # 4. Esperar hasta 8 segundos a que el servidor en Tailscale esté accesible
    notify-send "Cirrus F3" "Localizando servidor remoto ($CIRRUS_HOST)..." -i network-server -t 3000
    local attempts=0
    while ! ping -c 1 -W 1 "$CIRRUS_HOST" >/dev/null 2>&1; do
        sleep 1
        attempts=$((attempts + 1))
        if [ "$attempts" -ge 8 ]; then
            rm -f "$STATE_FILE"
            notify-send "Cirrus F3" "No se pudo alcanzar el servidor remoto ($CIRRUS_HOST)" -u critical -i dialog-error
            pkill -RTMIN+9 waybar 2>/dev/null || true
            return 1
        fi
    done

    # 5. Montar el recurso compartido CIFS
    notify-send "Cirrus F3" "Montando carpeta compartida..." -i network-server -t 2500
    if mount "$CIRRUS_MOUNT" 2>/dev/null; then
        rm -f "$STATE_FILE"
        notify-send "Cirrus F3" "Conectado y montado exitosamente en F3/NFS" -i folder-remote
        pkill -RTMIN+9 waybar 2>/dev/null || true
        return 0
    fi

    # Solicitar elevación con Polkit si es requerido
    if pkexec mount -t cifs "$CIRRUS_SERVER" "$CIRRUS_MOUNT" -o credentials="$CIRRUS_CREDS",vers=3.1.1,seal,rw,uid=$(id -u),gid=$(id -g),file_mode=0664,dir_mode=0775,noperm; then
        rm -f "$STATE_FILE"
        notify-send "Cirrus F3" "Conectado y montado exitosamente en F3/NFS" -i folder-remote
        pkill -RTMIN+9 waybar 2>/dev/null || true
        return 0
    else
        rm -f "$STATE_FILE"
        notify-send "Cirrus F3" "Error al montar recurso compartido" -u critical -i dialog-error
        pkill -RTMIN+9 waybar 2>/dev/null || true
        return 1
    fi
}

# Función para desmontar Cirrus F3
umount_cirrus() {
    if ! is_cirrus_mounted; then
        notify-send "Cirrus F3" "La carpeta ya se encuentra desmontada." -i folder
        pkill -f trayscale 2>/dev/null || true
        tailscale down 2>/dev/null || true
        pkill -RTMIN+9 waybar 2>/dev/null || true
        return 0
    fi

    echo "disconnecting" > "$STATE_FILE"
    trap 'rm -f "$STATE_FILE"; pkill -RTMIN+9 waybar 2>/dev/null || true' EXIT INT TERM
    pkill -RTMIN+9 waybar 2>/dev/null || true

    notify-send "Cirrus F3" "Desmontando recurso y apagando Tailscale..." -i network-server -t 3000

    if umount "$CIRRUS_MOUNT" 2>/dev/null || \
       pkexec umount "$CIRRUS_MOUNT"; then
        # Cerrar el cliente Trayscale
        pkill -f trayscale 2>/dev/null || true

        # Desconectar Tailscale para ahorrar recursos y batería
        tailscale down 2>/dev/null || true

        rm -f "$STATE_FILE"
        notify-send "Cirrus F3" "Desmontado exitosamente y red detenida" -i folder
        pkill -RTMIN+9 waybar 2>/dev/null || true
        return 0
    else
        rm -f "$STATE_FILE"
        notify-send "Cirrus F3" "Error al desmontar carpeta (verifique archivos en uso)" -u critical -i dialog-error
        pkill -RTMIN+9 waybar 2>/dev/null || true
        return 1
    fi
}

# ------------------------------------------------------------------------------
# DISPATCHER DE COMANDOS
# ------------------------------------------------------------------------------
case "$1" in
    mount)
        mount_cirrus
        ;;

    umount|unmount)
        umount_cirrus
        ;;

    toggle)
        if is_cirrus_mounted; then
            umount_cirrus
        else
            mount_cirrus
        fi
        ;;

    open)
        if is_cirrus_mounted; then
            thunar "$CIRRUS_MOUNT" &
        else
            notify-send "Cirrus F3" "El recurso no está montado. Haz clic izquierdo para montarlo." -i folder
        fi
        ;;

    status|*)
        if [ -f "$STATE_FILE" ]; then
            echo '{"text": "󰋊", "tooltip": "Cirrus F3: Conectando y montando recurso...", "class": "connecting"}'
        elif is_cirrus_mounted; then
            echo "{\"text\": \"󰋊\", \"tooltip\": \"Cirrus F3: Montado (Activo)\nRuta: $CIRRUS_MOUNT\nServidor: $CIRRUS_SERVER\n\nClic izquierdo: Desmontar\nClic derecho: Abrir en Thunar\", \"class\": \"mounted\"}"
        else
            echo '{"text": "󰋊", "tooltip": "Cirrus F3: Desmontado (Inactivo)\n\nClic izquierdo: Montar e iniciar Tailscale", "class": "unmounted"}'
        fi
        ;;
esac
