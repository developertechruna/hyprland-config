# =====================================================================
# Prompt Catppuccin Mocha para Zsh
# =====================================================================
# Ubicación destino: ~/.config/zsh/prompt.zsh

# Si starship está instalado, delegar a Starship
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
    return 0
fi

setopt prompt_subst

autoload -Uz vcs_info
autoload -Uz add-zsh-hook

# Configuración de vcs_info para Git
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr '%F{#a6e3a1}✚%f'
zstyle ':vcs_info:git:*' unstagedstr '%F{#f38ba8}●%f'
zstyle ':vcs_info:git:*' formats '%F{#cba6f7} %b%f %c%u'
zstyle ':vcs_info:git:*' actionformats '%F{#cba6f7} %b%f|%F{#fab387}%a%f %c%u'

# Función para verificar archivos sin seguimiento y estado remoto de git
_prompt_git_extra() {
    [[ -n "$vcs_info_msg_0_" ]] || return
    local extra=""
    
    # Untracked files
    if command git status --porcelain 2>/dev/null | command grep -q '^??'; then
        extra+="%F{#f9e2af}…%f"
    fi

    # Commits por subir (ahead) o por bajar (behind)
    local upstream
    upstream=$(command git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
    if [[ -n "$upstream" ]]; then
        local counts
        counts=$(command git rev-list --left-right --count HEAD..."$upstream" 2>/dev/null)
        if [[ -n "$counts" ]]; then
            local ahead=${counts%%	*}
            local behind=${counts##*	}
            [[ "$ahead" -gt 0 ]] && extra+="%F{#89dceb}⇡${ahead}%f"
            [[ "$behind" -gt 0 ]] && extra+="%F{#eba0ac}⇣${behind}%f"
        fi
    fi

    if [[ -n "$extra" ]]; then
        echo -n " $extra"
    fi
}

_prompt_git_info() {
    if [[ -n "$vcs_info_msg_0_" ]]; then
        echo -n " %F{#6c7086}on%f ${vcs_info_msg_0_}$(_prompt_git_extra)"
    fi
}

# Ejecutar vcs_info antes de cada prompt
precmd_vcs_info() {
    vcs_info
}
add-zsh-hook precmd precmd_vcs_info

# Indicador de usuario: Si es root se muestra rojo, si es SSH se muestra user@host
_prompt_user() {
    if [[ "$EUID" -eq 0 ]]; then
        echo -n "%F{#f38ba8} root%f"
    elif [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
        echo -n "%F{#fab387}󰢹 %n@%m%f"
    else
        echo -n "%F{#89b4fa} %n%f"
    fi
}

# Línea 1: Conector, Usuario, Directorio y Git
# Línea 2: Conector y Flecha de ejecución (Verde éxito / Roja fallo)
PROMPT='%F{#585b70}╭─%f $(_prompt_user) %F{#6c7086}in%f %F{#89dceb}󰉋 %~%f$(_prompt_git_info)
%F{#585b70}╰─%f%(?.%F{#a6e3a1}❯%f.%F{#f38ba8}❯%f) '

# Prompt Derecho (RPROMPT): Código de error (si falló) y Hora actual
RPROMPT='%(?..%F{#f38ba8}[error %?]%f )%F{#585b70}%*%f'
