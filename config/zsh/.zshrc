# =====================================================================
# Configuración Principal de ZSH (Catppuccin Mocha - Developer Edition)
# =====================================================================
# Ubicación destino: ~/.zshrc y ~/.config/zsh/.zshrc

# ---------------------------------------------------------------------
# 1. VARIABLES DE ENTORNO Y RUTAS
# ---------------------------------------------------------------------
# Editor predeterminado para git, crontab y terminal
if command -v nvim >/dev/null 2>&1; then
    export EDITOR='nvim'
    export VISUAL='nvim'
else
    export EDITOR='nano'
    export VISUAL='nano'
fi

export PAGER='less'
export LESS='-R --use-color -Dd+r$Du+b'

# Compatibilidad con Wayland para aplicaciones gráficas
export MOZ_ENABLE_WAYLAND=1
export _JAVA_AWT_WM_NONREPARENTING=1
export QT_QPA_PLATFORM="wayland;xcb"

# Servidor MPD local (Cantata / mpc / ncmpcpp)
export MPD_HOST="127.0.0.1"
export MPD_PORT="6600"

# Expansión de PATH para binarios locales y herramientas de desarrollo
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"
[[ -d "$HOME/.cargo/bin" ]] && export PATH="$HOME/.cargo/bin:$PATH"
[[ -d "$HOME/go/bin" ]] && export PATH="$HOME/go/bin:$PATH"

# Configuración y rutas de JDKs (Java)
export JDK7_HOME="/home/johnny/Apps/jdks/jdk1.7.0_80"
export JDK8_HOME="/home/johnny/Apps/jdks/jdk1.8.0_461"
# Si JAVA_HOME ya viene definido (por ejemplo por perfiles de terminal JDK 7 o JDK 8), respetarlo;
# de lo contrario, se mantiene el JDK global del sistema (conmutables con 'jdk7', 'jdk8' o 'setjdk')
if [[ -n "$JAVA_HOME" && -d "$JAVA_HOME/bin" ]]; then
    export PATH="$JAVA_HOME/bin:$PATH"
fi


# ---------------------------------------------------------------------
# 2. HISTORIAL DE COMANDOS INTELIGENTE
# ---------------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt EXTENDED_HISTORY          # Guarda marca de tiempo y duración
setopt SHARE_HISTORY             # Comparte el historial entre terminales abiertas
setopt HIST_EXPIRE_DUPS_FIRST    # Borra duplicados primero cuando se llena el historial
setopt HIST_IGNORE_DUPS          # No registra comandos duplicados consecutivos
setopt HIST_IGNORE_ALL_DUPS      # Elimina duplicados anteriores si se repite el comando
setopt HIST_FIND_NO_DUPS         # No muestra duplicados al buscar hacia atrás
setopt HIST_IGNORE_SPACE         # Comandos con espacio al inicio no se guardan (seguridad)
setopt HIST_SAVE_NO_DUPS         # No guarda duplicados en el archivo del historial
setopt HIST_REDUCE_BLANKS        # Elimina espacios en blanco innecesarios
setopt HIST_VERIFY               # Muestra el comando antes de ejecutarlo con '!'
setopt INC_APPEND_HISTORY_TIME   # Guarda inmediatamente tras ejecutar cada comando

# ---------------------------------------------------------------------
# 3. OPCIONES DE NAVEGACIÓN Y COMPORTAMIENTO
# ---------------------------------------------------------------------
setopt AUTO_CD                   # Entrar a un directorio solo escribiendo su nombre
setopt AUTO_PUSHD                # Guarda directorios visitados en una pila (cd -)
setopt PUSHD_IGNORE_DUPS         # No duplicar directorios en la pila
setopt PUSHD_SILENT              # No imprimir la pila en cada pushd/popd
setopt INTERACTIVE_COMMENTS      # Permitir comentarios (#) en la consola interactiva
setopt NO_BEEP                   # Silenciar pitidos molestos de la terminal
setopt COMPLETE_IN_WORD          # Permitir autocompletar en medio de una palabra

# ---------------------------------------------------------------------
# 4. OH-MY-ZSH / GESTIÓN DE AUTOCOMPLETADO
# ---------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"

if [[ -d "$ZSH" ]]; then
    # Deshabilitar tema de Oh-My-Zsh para usar nuestro prompt Catppuccin Mocha nativo
    ZSH_THEME=""
    
    # Plugins oficiales de Oh-My-Zsh
    plugins=(git sudo extract colored-man-pages copypath copyfile)
    
    # Cargar Oh-My-Zsh
    source "$ZSH/oh-my-zsh.sh"
else
    # Inicialización estándar de compinit con caché rápida si no se usa OMZ
    autoload -Uz compinit
    typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || echo 0)
    if [ $(date +'%j') != $updated_at ]; then
        compinit -i
    else
        compinit -C -i
    fi
fi

# Ajustes de estilo para el autocompletado
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' menu select=2
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{#89dceb}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{#f38ba8}No se encontraron coincidencias para:%f %d'
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$HOME/.cache/zsh"

# ---------------------------------------------------------------------
# 5. ATAJOS DE TECLADO (KEYBINDINGS)
# ---------------------------------------------------------------------
bindkey -e # Modo Emacs por defecto

# Teclas estándar Inicio, Fin y Suprimir
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[3;5~' delete-char

# Navegación palabra por palabra con Ctrl + Flechas
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[^[[C' forward-word
bindkey '^[^[[D' backward-word

# Abrir el comando actual en Neovim con Ctrl + X, Ctrl + E
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line
bindkey '^x^e' edit-command-line

# Alternar rápidamente entre segundo plano y primer plano con Ctrl + Z (como en vim/lazygit)
fancy-ctrl-z() {
    if [[ $#BUFFER -eq 0 ]]; then
        BUFFER="fg"
        zle accept-line
    else
        zle push-input
        zle clear-screen
    fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# ---------------------------------------------------------------------
# 6. CONFIGURACIÓN DE COLORES CATPPUCCIN MOCHA PARA PLUGINS
# ---------------------------------------------------------------------
# Autosuggestions: color Overlay0 (#6c7086) sutil y legible en tema oscuro
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Syntax Highlighting: Paleta armonizada de Catppuccin Mocha
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#89b4fa,bold'          # Blue
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#89dceb'               # Sky
ZSH_HIGHLIGHT_STYLES[alias]='fg=#b4befe'                 # Lavender
ZSH_HIGHLIGHT_STYLES[function]='fg=#89b4fa'              # Blue
ZSH_HIGHLIGHT_STYLES[path]='fg=#a6e3a1,underline'        # Green
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#a6e3a1' # Green
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#a6e3a1' # Green
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#f9e2af' # Yellow
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#f5c2e7'      # Pink
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#f5c2e7'           # Pink
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f38ba8'         # Red
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#cba6f7,bold'    # Mauve
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#fab387'  # Peach
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#fab387'  # Peach

# ---------------------------------------------------------------------
# 7. CARGA DE PLUGINS DEL SISTEMA (Arch Linux Pacman / Yay)
# ---------------------------------------------------------------------
# zsh-autosuggestions
if [[ -f "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [[ -f "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
# Atajo para aceptar autosugerencia con Ctrl + Espacio (además de la flecha derecha ->)
bindkey '^ ' autosuggest-accept 2>/dev/null || true
bindkey '^@' autosuggest-accept 2>/dev/null || true

# zsh-history-substring-search y vinculación de flechas Arriba/Abajo
if [[ -f "/usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
    source "/usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
elif [[ -f "$HOME/.oh-my-zsh/custom/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
    source "$HOME/.oh-my-zsh/custom/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
fi

if (( $+widgets[history-substring-search-up] )); then
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    bindkey "$terminfo[kcuu1]" history-substring-search-up 2>/dev/null
    bindkey "$terminfo[kcud1]" history-substring-search-down 2>/dev/null
else
    autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
    zle -N up-line-or-beginning-search
    zle -N down-line-or-beginning-search
    bindkey '^[[A' up-line-or-beginning-search
    bindkey '^[[B' down-line-or-beginning-search
fi

# zsh-syntax-highlighting (Siempre debe cargarse después de los demás plugins)
if [[ -f "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [[ -f "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# ---------------------------------------------------------------------
# 8. MÓDULOS DEL ENTORNO (Prompt, Alias, Funciones)
# ---------------------------------------------------------------------
# Si ZDOTDIR tiene los módulos (o si no, usar ~/.config/zsh)
if [[ -n "$ZDOTDIR" && -f "$ZDOTDIR/prompt.zsh" ]]; then
    ZSH_CONFIG_DIR="$ZDOTDIR"
elif [[ -f "$HOME/.config/zsh/prompt.zsh" ]]; then
    ZSH_CONFIG_DIR="$HOME/.config/zsh"
elif [[ -d "$HOME/Projects/desktop/desktop-for-developer/config/zsh" ]]; then
    ZSH_CONFIG_DIR="$HOME/Projects/desktop/desktop-for-developer/config/zsh"
else
    ZSH_CONFIG_DIR="$HOME/.config/zsh"
fi

[[ -f "$ZSH_CONFIG_DIR/prompt.zsh" ]] && source "$ZSH_CONFIG_DIR/prompt.zsh"
[[ -f "$ZSH_CONFIG_DIR/aliases.zsh" ]] && source "$ZSH_CONFIG_DIR/aliases.zsh"
[[ -f "$ZSH_CONFIG_DIR/functions.zsh" ]] && source "$ZSH_CONFIG_DIR/functions.zsh"

# Cargar configuraciones privadas/locales adicionales si existen
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
