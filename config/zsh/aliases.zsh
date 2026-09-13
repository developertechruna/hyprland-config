# =====================================================================
# Alias para Desarrollador en Zsh (Catppuccin Mocha Environment)
# =====================================================================
# Ubicación destino: ~/.config/zsh/aliases.zsh

# ---------------------------------------------------------------------
# 1. NAVEGACIÓN RÁPIDA
# ---------------------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias dots='cd ~/Projects/desktop/desktop-for-developer'
alias proj='cd ~/Projects'
alias desk='cd ~/Desktop'
alias dl='cd ~/Downloads'

# ---------------------------------------------------------------------
# 2. HERRAMIENTAS MODERNAS DE TERMINAL (Detección dinámica)
# ---------------------------------------------------------------------
# Reemplazo de ls con eza (si está disponible)
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --group-directories-first --icons'
    alias ll='eza -la --group-directories-first --icons --git'
    alias la='eza -a --group-directories-first --icons'
    alias lt='eza --tree --level=2 --icons'
    alias ltree='eza --tree --icons'
else
    alias ls='ls --color=auto --group-directories-first'
    alias ll='ls -lah --color=auto --group-directories-first'
    alias la='ls -A --color=auto --group-directories-first'
fi

# Reemplazo de cat con bat (si está disponible)
if command -v bat >/dev/null 2>&1; then
    alias cat='bat --style=plain --paging=never'
    alias preview='bat --style=numbers,changes --color=always'
fi

# Reemplazo de htop/top con btop (si está disponible)
if command -v btop >/dev/null 2>&1; then
    alias top='btop'
    alias htop='btop'
fi

# Editores y TUI
alias v='nvim'
alias vim='nvim'
alias vi='nvim'
alias lg='lazygit'
alias y='yazi'

# ---------------------------------------------------------------------
# 3. SEGURIDAD Y GENERALES
# ---------------------------------------------------------------------
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias mkdir='mkdir -pv'
alias df='df -h'
alias free='free -h'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias c='clear'
alias reload='source ~/.zshrc && echo "Configuración de Zsh recargada."'

# ---------------------------------------------------------------------
# 4. GIT
# ---------------------------------------------------------------------
alias g='git'
alias gst='git status -sb'
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gsw='git switch'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull --rebase'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
alias gb='git branch -vv'
alias gclean='git clean -fd'

# ---------------------------------------------------------------------
# 5. GESTIÓN DE PAQUETES ARCH LINUX (Pacman & Yay)
# ---------------------------------------------------------------------
alias pacin='sudo pacman -S'
alias pacup='sudo pacman -Syu'
alias pacrem='sudo pacman -Rns'
alias pacsearch='pacman -Ss'
alias pacinfo='pacman -Si'
alias yayin='yay -S'
alias yayup='yay -Syu'
alias yaysearch='yay -Ss'
alias pacclean='sudo pacman -Sc && yay -Sc'
# Listar paquetes huérfanos
alias pacorphans='pacman -Qtdq'

# ---------------------------------------------------------------------
# 6. ENTORNO WAYLAND, IDES Y ESCRITORIO
# ---------------------------------------------------------------------
alias clip='wl-copy'
alias paste='wl-paste'
alias eclipse-wayland='env GDK_BACKEND=wayland _JAVA_AWT_WM_NONREPARENTING=1 eclipse >/dev/null 2>&1 &'
alias antigravity-wayland='antigravity-ide --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime >/dev/null 2>&1 &'
alias apply-dots='(cd ~/Projects/desktop/desktop-for-developer && ./apply.sh)'

# Red e Información
alias ports='ss -tulanp'
alias pingg='ping -c 5 1.1.1.1'
