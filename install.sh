sudo pacman -S --needed git base-devel;
#sudo yay -S --needed hyprland waybar xfce4-terminal mako pipewire pipewire-alsa pipewire-pulse wireplumber polkit-gnome xdg-desktop-portal-hyprland qt5-wayland qt6-wayland brightnessctl pamixer playerctl grim slurp wl-clipboard swappy flameshot btop network-manager-applet pavucontrol blueman ttf-jetbrains-mono ttf-font-awesome git lazygit yazi rofi-wayland cliphist zsh zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search zsh-completions eza bat fzf;
yay -S --needed hyprland hyprlock hypridle waybar xfce4-terminal swaync pipewire pipewire-alsa pipewire-pulse wireplumber polkit-gnome xdg-desktop-portal-hyprland qt5-wayland qt6-wayland brightnessctl pamixer playerctl grim slurp wl-clipboard swappy flameshot btop network-manager-applet pavucontrol blueman mpd cantata mpc ttf-sourcecodepro-nerd ttf-jetbrains-mono otf-fira-code ttf-font-awesome noto-fonts-cjk noto-fonts-emoji ttf-nerd-fonts-symbols git lazygit yazi rofi-wayland cliphist wlogout zsh zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search zsh-completions eza bat fzf;

yay -S --needed awww nwg-drawer nwg-dock-hyprland;

# Plugins nativos de Hyprland (requieren Hyprland >= 0.56), compilados con hyprpm desde la sesión de Hyprland:
#  - HyprCapture: capturas de pantalla y grabación
#  - Hymission:   vista general de ventanas estilo Mission Control
yay -S --needed hyprpm cmake cpio nlohmann-json qt6-base qt6-svg layer-shell-qt opencv libpipewire fftw libpulse ffmpeg x265 libde265 libjpeg-turbo gtk4 gtk4-layer-shell libadwaita;
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    hyprpm update;
    hyprpm add https://github.com/gfhdhytghd/HyprCapture;
    hyprpm add https://github.com/gfhdhytghd/hymission;
    hyprpm enable hyprcapture;
    hyprpm enable hymission;
    hyprpm reload;
else
    echo "Plugins: ejecuta dentro de la sesión de Hyprland:";
    echo "  hyprpm update && hyprpm add https://github.com/gfhdhytghd/HyprCapture && hyprpm add https://github.com/gfhdhytghd/hymission && hyprpm enable hyprcapture && hyprpm enable hymission && hyprpm reload";
fi
# Paso 4: Copiar la configuración creada al directorio home
# cp -r config/* ~/.config/
#
# Paso 5: Ejecutar Hyprland
# Hyprland
