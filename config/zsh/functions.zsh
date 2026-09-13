# =====================================================================
# Funciones Utilitarias para Desarrollador en Zsh
# =====================================================================
# Ubicación destino: ~/.config/zsh/functions.zsh

# Crear directorio y entrar inmediatamente
mkcd() {
    if [[ -z "$1" ]]; then
        echo "Uso: mkcd <nombre_directorio>"
        return 1
    fi
    mkdir -p "$1" && cd "$1"
}

# Subir N niveles de directorios (ejemplo: up 3 equivale a cd ../../..)
up() {
    local d=""
    local limit=${1:-1}
    for ((i=1; i<=limit; i++)); do
        d="../$d"
    done
    cd "$d"
}

# Descompresor universal para cualquier formato
extract() {
    if [[ -z "$1" ]]; then
        echo "Uso: extract <archivo_comprimido>"
        return 1
    fi

    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *.tar.xz)    tar xf "$1"      ;;
            *.tar.zst)   tar --zstd -xf "$1" ;;
            *)           echo "No se reconoce el formato de '$1'" ;;
        esac
    else
        echo "'$1' no es un archivo válido"
    fi
}

# Matar el proceso que esté escuchando en un puerto específico
killport() {
    if [[ -z "$1" ]]; then
        echo "Uso: killport <puerto>"
        return 1
    fi
    local pid
    pid=$(lsof -ti tcp:"$1")
    if [[ -n "$pid" ]]; then
        echo "Matando proceso con PID $pid en puerto $1..."
        kill -9 "$pid"
    else
        echo "No hay procesos escuchando en el puerto $1."
    fi
}

# Mostrar IP pública y privada
myip() {
    echo -n "IP Local:  "
    ip route get 1.1.1.1 2>/dev/null | awk '{print $7}' || echo "No conectado"
    echo -n "IP Pública: "
    curl -s --connect-timeout 2 ifconfig.me 2>/dev/null || echo "No disponible"
    echo ""
}

# Crear una copia de respaldo rápida de un archivo con marca de tiempo
backup() {
    if [[ -z "$1" ]]; then
        echo "Uso: backup <archivo>"
        return 1
    fi
    if [[ -e "$1" ]]; then
        local target="${1}.bak.$(date +%Y%m%d_%H%M%S)"
        cp -r "$1" "$target"
        echo "Respaldo creado: $target"
    else
        echo "El archivo o carpeta '$1' no existe."
    fi
}
