-- Configuración moderna nativa de Hyprland (Lua API - Hyprland 0.56+)
-- Ubicación destino: ~/.config/hypr/hyprland.lua
-- Referencia oficial: https://wiki.hypr.land/Configuring/Start/

------------------
---- MONITORES ----
------------------
-- Detecta automáticamente la resolución y tasa de refresco recomendadas
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

---------------------
---- VARIABLES DE ENTORNO ----
---------------------
-- Compatibilidad con Wayland, XDG, Toolkits y Cursores
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "catppuccin-mocha-sapphire-cursors")
hl.env("HYPRCURSOR_THEME", "catppuccin-mocha-sapphire-cursors")

-- Compatibilidad Java AWT / Swing (IDEs Java / NetBeans)
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")

-- Servidor MPD local (Cantata / mpc)
hl.env("MPD_HOST", "127.0.0.1")
hl.env("MPD_PORT", "6600")

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    -- Sincronización de entorno para D-Bus y Portales XDG
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP PATH")
    hl.exec_cmd("systemctl --user restart xdg-desktop-portal.service")

    -- Componentes principales de la interfaz
    hl.exec_cmd("waybar")                                            -- Barra superior
    hl.exec_cmd("awww-daemon")                                       -- Servidor de fondos de pantalla
    hl.exec_cmd("bash ~/.config/hypr/wallpaper_loop.sh")             -- Rotación de fondos
    hl.exec_cmd("swaync")                                            -- Centro de notificaciones
    hl.exec_cmd("nm-applet --indicator")                               -- Bandeja de red / VPN
    hl.exec_cmd("blueman-applet")                                    -- Bandeja de Bluetooth
    hl.exec_cmd("hypridle")                                          -- Administrador de inactividad

    -- Historial del portapapeles
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Agente de autenticación Polkit
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

    -- Scripts de experiencia de usuario y temas
    hl.exec_cmd("~/.config/hypr/drag_edge.py")
    hl.exec_cmd("python3 ~/.config/hypr/launch_docks.py")
    hl.exec_cmd("bash ~/.config/hypr/set_gtk.sh")
    hl.exec_cmd("flameshot &")
    hl.exec_cmd("bash ~/.config/hypr/power_notify.sh")
end)

-----------------------
---- CONFIGURACIÓN GENERAL Y ESTILO ----
-----------------------
hl.config({
    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
    },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
    },

    cursor = {
        no_hardware_cursors = 2,
        sync_gsettings_theme = true,
        enable_hyprcursor = true,
    },

    input = {
        kb_layout = "us,latam",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true,
        },
        sensitivity = 0,
    },

    general = {
        gaps_in = 3,
        gaps_out = { top = 1, right = 5, bottom = 5, left = 5 },
        border_size = 2,

        col = {
            active_border = { colors = { "rgb(74c7ec)", "rgb(89b4fa)" }, angle = 45 },
            inactive_border = "rgba(313244aa)",
        },

        layout = "dwindle",
        resize_on_border = false,
        allow_tearing = false,
    },

    decoration = {
        rounding = 6,
        rounding_power = 2.0,
        active_opacity = 0.98,
        inactive_opacity = 0.90,

        blur = {
            enabled = true,
            size = 6,
            passes = 2,
            new_optimizations = true,
            ignore_opacity = true,
            xray = false,
        },

        shadow = {
            enabled = true,
            range = 15,
            render_power = 3,
            color = "rgba(11111b88)",
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },
})

---------------------
---- ANIMACIONES ----
---------------------
hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.animation({ leaf = "windows",     enabled = true, speed = 4, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 4, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 3, bezier = "default" })

-----------------------
---- ATAJOS DE TECLADO ----
-----------------------
local mainMod = "SUPER"

-- Cambio de distribución de teclado y actualización de mayúsculas
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("python3 ~/.config/hypr/switch_layout.py"))
hl.bind("Caps_Lock",          hl.dsp.exec_cmd("pkill -RTMIN+1 waybar"))

-- Lanzadores de aplicaciones
hl.bind(mainMod .. " + RETURN",   hl.dsp.exec_cmd("which kitty >/dev/null 2>&1 && kitty || xfce4-terminal"))
hl.bind(mainMod .. " + B",        hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + E",        hl.dsp.exec_cmd("thunar"))
hl.bind(mainMod .. " + D",        hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("nwg-drawer"))
hl.bind(mainMod .. " + M",        hl.dsp.exec_cmd("nwg-drawer"))
hl.bind(mainMod .. " + A",        hl.dsp.exec_cmd("python3 ~/.config/hypr/toggle_dock.py"))
hl.bind(mainMod .. " + Escape",   hl.dsp.exec_cmd("wlogout"))
hl.bind(mainMod .. " + P",        hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + N",        hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -d -sw"))

-- Control de Ventanas y Sistema
hl.bind(mainMod .. " + Q",         hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.exec_cmd("hyprctl kill"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())
hl.bind(mainMod .. " + V",         hl.dsp.window.float({ action = "toggle" }))
hl.bind("ALT + Tab",               hl.dsp.exec_cmd("rofi -show window"))
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + S",         hl.dsp.exec_cmd("XDG_CURRENT_DESKTOP=sway flameshot gui"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy -t image/png'))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))

-- Foco entre ventanas (estilo Vim: H, J, K, L)
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Workspaces 1 al 10 (Foco y Movimiento)
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Navegación relativa entre workspaces
hl.bind(mainMod .. " + left",          hl.dsp.focus({ workspace = "r-1" }))
hl.bind(mainMod .. " + right",         hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ workspace = "r-1" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Mover y redimensionar ventanas con el ratón
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Controles multimedia (Volumen y Brillo)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("bash ~/.config/hypr/toggle_mic.sh"),          { locked = true })
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("bash ~/.config/hypr/toggle_mic.sh"))
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"),                      { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"),                      { repeating = true })

-- Control de reproducción multimedia
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause || mpc toggle"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next || mpc next"),         { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous || mpc prev"),     { locked = true })

-- Gestos de touchpad para cambiar de workspace
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

---------------------------------
---- REGLAS DE VENTANA Y CAPA ----
---------------------------------
-- Reglas generales de estabilidad
hl.window_rule({
    name = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

-- Eclipse IDE
hl.window_rule({
    name = "eclipse-dialogs",
    match = {
        class = "^([Ee]clipse)$",
        title = "^(.*)(Dialog|Properties|Preferences|Wizard|Settings|New|Open|Save|Select|Progress|Confirm|Find|Search|Replace|Refactor|Rename|Git|Commit|Push|Pull|Merge|Update|Error|Warning|Information).*$",
    },
    float = true,
    center = true,
})
hl.window_rule({
    name = "eclipse-select",
    match = { class = "^([Ee]clipse)$", title = "^(Select).*$" },
    float = true,
    center = true,
})
hl.window_rule({
    name = "eclipse-progress",
    match = { class = "^([Ee]clipse)$", title = "^(Progress).*$" },
    float = true,
    center = true,
})
hl.window_rule({
    name = "eclipse-confirm",
    match = { class = "^([Ee]clipse)$", title = "^(Confirm).*$" },
    float = true,
    center = true,
})

-- Antigravity IDE
hl.window_rule({
    name = "code-url-handler",
    match = { class = "^(code-url-handler)$" },
    float = true,
})
hl.window_rule({
    name = "antigravity-ide-dialogs",
    match = {
        class = "^(antigravity-ide)$",
        title = "^(Open Folder|Open File|Save As|Confirm|Preferences|Settings).*$",
    },
    float = true,
    center = true,
})

-- Thunar
hl.window_rule({
    name = "thunar-dialogs",
    match = {
        class = "^([Tt]hunar)$",
        title = "^(.*)(Dialog|Properties|Propiedades|Preferences|Preferencias|Progress|Progreso|Conflict|Conflicto|Confirm|Confirmar|Create|Crear|Rename|Renombrar|Choose|Select|Seleccionar|Open|Abrir|Save|Guardar|Extract|Extraer|Error|Warning|Advertencia|Copying|Moving|Deleting|Eliminar).*$",
    },
    float = true,
    center = true,
})

-- Utilidades flotantes
hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" }, float = true })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" },      float = true })
hl.window_rule({ match = { class = "^(blueman-manager)$" },           float = true })
hl.window_rule({ match = { class = "^(blueman-adapters)$" },          float = true })
hl.window_rule({ match = { class = "^(nm-applet)$" },                  float = true })

hl.window_rule({
    name = "floating-terminal",
    match = { class = "^(floating_terminal)$" },
    float = true,
    center = true,
    size = "750 500",
})

hl.window_rule({
    name = "nm-openconnect",
    match = { class = "^(nm-openconnect-auth-dialog)$" },
    float = true,
    center = true,
    size = "550 450",
})

hl.window_rule({
    name = "vokoscreen",
    match = { class = "^([Vv]okoscreen.*)$" },
    float = true,
    center = true,
    size = "500 700",
})

hl.window_rule({
    name = "cantata-dialogs",
    match = {
        class = "^(.*[Cc]antata.*)$",
        title = "^(.*)(Preferences|Preferencias|Settings|Configuración|Initial Settings|Properties|Propiedades).*$",
    },
    float = true,
    center = true,
})

hl.window_rule({
    name = "picture-in-picture",
    match = { title = "^(.*)(Picture-in-Picture|Picture-in-picture|Picture in picture|Imagen en imagen)(.*)$" },
    float = true,
    pin = true,
    size = "450 255",
})

hl.window_rule({
    name = "libreoffice-dialogs",
    match = {
        class = "^(soffice|libreoffice.*)$",
        title = "^(Open|Abrir|Save|Guardar|Save As|Guardar como|Confirm|Properties|Choose|Select|Select a File|Seleccionar un archivo)$",
    },
    float = true,
    center = true,
})

hl.window_rule({
    name = "xfce4-appfinder",
    match = { class = "^(xfce4-appfinder)$" },
    float = true,
    center = true,
    size = "800 500",
})
hl.window_rule({
    name = "appfinder-title",
    match = { title = "^(Application Finder)$" },
    float = true,
    center = true,
    size = "800 500",
})

hl.window_rule({
    name = "terminal-opacity-xfce",
    match = { class = "^(xfce4-terminal)$" },
    opacity = "0.94 0.88",
})
hl.window_rule({
    name = "terminal-opacity-kitty",
    match = { class = "^(kitty)$" },
    opacity = "0.94 0.88",
})

hl.window_rule({
    name = "flameshot",
    match = { class = "^([Ff]lameshot)$" },
    float = true,
    center = true,
    pin = true,
    no_anim = true,
    stay_focused = true,
})

-- Reglas de capas (Layer Rules para Waybar, Rofi y SwayNC)
hl.layer_rule({
    name = "waybar-blur",
    match = { namespace = "^(waybar)$" },
    blur = true,
})
hl.layer_rule({
    name = "rofi-blur",
    match = { namespace = "^(rofi)$" },
    blur = true,
    ignore_alpha = 0.5,
})
hl.layer_rule({
    name = "swaync-blur",
    match = { namespace = "^(swaync.*)$" },
    blur = true,
    ignore_alpha = 0.5,
})
