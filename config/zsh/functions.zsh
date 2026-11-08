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

# =====================================================================
# Gestión y Conmutación Rápida de Versiones de JDK y Maven (Java)
# =====================================================================
# Cargar configuración personal si existe
[[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/desktop/desktop.conf" ]] && source "${XDG_CONFIG_HOME:-$HOME/.config}/desktop/desktop.conf"

export JDK6_HOME="${JDK6_HOME:-$HOME/Apps/jdks/jdk1.6.0_45}"
export JDK7_HOME="${JDK7_HOME:-$HOME/Apps/jdks/jdk1.7.0_80}"
export JDK8_HOME="${JDK8_HOME:-$HOME/Apps/jdks/jdk1.8.0_461}"
export MAVEN_32_HOME="${MAVEN_32_HOME:-$HOME/Apps/apache-maven-3.2.5}"

setjdk() {
    local version="$1"
    local target=""
    local target_mvn=""

    case "$version" in
        6|1.6)
            target="$JDK6_HOME"
            target_mvn="$MAVEN_32_HOME"
            ;;
        7|1.7)
            target="$JDK7_HOME"
            target_mvn="$MAVEN_32_HOME"
            ;;
        8|1.8)
            target="$JDK8_HOME"
            target_mvn=""
            ;;
        system|sys|default|17)
            export JAVA_HOME=""
            unset MAVEN_HOME M2_HOME
            export PATH="$(echo "$PATH" | tr ':' '\n' | grep -vE '/(Apps|opt)/(jdks|apache-maven)' | tr '\n' ':' | sed 's/:$//')"
            echo "Restablecido a JDK y Maven del sistema."
            command -v java >/dev/null 2>&1 && java -version
            command -v mvn >/dev/null 2>&1 && mvn -version | head -n 1
            return 0
            ;;
        *)
            echo "Uso: setjdk <6|7|8|system> (o escribe 'jdk6' / 'jdk7' / 'jdk8')"
            echo ""
            echo "Entornos configurados:"
            echo "  6 -> JDK 1.6 ($JDK6_HOME) + Maven 3.2.5"
            echo "  7 -> JDK 1.7 ($JDK7_HOME) + Maven 3.2.5"
            echo "  8 -> JDK 1.8 ($JDK8_HOME) + Maven del sistema"
            echo "  system -> Predeterminado del sistema"
            echo ""
            echo "JAVA_HOME actual:  ${JAVA_HOME:-Sistema}"
            echo "MAVEN_HOME actual: ${MAVEN_HOME:-Sistema}"
            if command -v java >/dev/null 2>&1; then
                java -version
            fi
            if command -v mvn >/dev/null 2>&1; then
                mvn -version | head -n 1
            fi
            return 1
            ;;
    esac

    if [[ -d "$target" ]]; then
        export JAVA_HOME="$target"
        # Limpiar versiones previas de JDK y Maven en PATH
        export PATH="$(echo "$PATH" | tr ':' '\n' | grep -vE '/(Apps|opt)/(jdks|apache-maven)' | tr '\n' ':' | sed 's/:$//')"
        
        # Configurar Maven compatible si aplica
        if [[ -n "$target_mvn" && -d "$target_mvn" ]]; then
            export MAVEN_HOME="$target_mvn"
            export M2_HOME="$target_mvn"
            export PATH="$MAVEN_HOME/bin:$PATH"
        else
            unset MAVEN_HOME M2_HOME
        fi

        export PATH="$JAVA_HOME/bin:$PATH"
        echo "JAVA_HOME configurado a: $JAVA_HOME"
        [[ -n "$MAVEN_HOME" ]] && echo "MAVEN_HOME configurado a: $MAVEN_HOME"
        java -version
        command -v mvn >/dev/null 2>&1 && mvn -version | head -n 1
    else
        echo "Error: El directorio '$target' no existe."
        return 1
    fi
}

jdk6() { setjdk 6; }
jdk7() { setjdk 7; }
jdk8() { setjdk 8; }

