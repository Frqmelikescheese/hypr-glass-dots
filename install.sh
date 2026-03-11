#!/bin/bash

# --- frqme-glass-rice Installer (Aesthetic Edition) ---

# Colors
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Helper for animations
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

clear
echo -e "${CYAN}"
echo "  ███████╗██████╗  ██████╗ ███╗   ███╗███████╗"
echo "  ██╔════╝██╔══██╗██╔═══██╗████╗ ████║██╔════╝"
echo "  █████╗  ██████╔╝██║   ██║██╔████╔██║█████╗  "
echo "  ██╔══╝  ██╔══██╗██║   ██║██║╚██╔╝██║██╔══╝  "
echo "  ██║     ██║  ██║╚██████╔╝██║ ╚═╝ ██║███████╗"
echo "  ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝"
echo "                                              "
echo -e "  ${WHITE}ULTIMATE GLASS RICE INSTALLER${NC}"
echo -e "  ${MAGENTA}------------------------------${NC}"
echo ""

# 1. Check Root
if [ "$EUID" -ne 0 ]; then
  echo -e "${MAGENTA}[!]${NC} Please run with sudo or as root"
  exit
fi

# 2. Dependencies
echo -e "${CYAN}[1/5]${NC} Installing system dependencies..."
DEPS=(
    hyprland waybar rofi kitty thunar fastfetch cava
    hyprpaper swaybg dunst nm-applet blueman
    pavucontrol brightnessctl pipewire-pulse wireplumber
    ttf-jetbrains-mono-nerd woff2-font-awesome
    nwg-look arc-gtk-theme papirus-icon-theme
)

(pacman -S --needed --noconfirm "${DEPS[@]}" > /dev/null 2>&1) & spinner $!
echo -e "${WHITE}Done.${NC}"

# 3. Backup
echo -e "${CYAN}[2/5]${NC} Backing up existing config..."
(mkdir -p ~/.config.backup-$(date +%s) && cp -rf ~/.config/* ~/.config.backup-$(date +%s)/ > /dev/null 2>&1) & spinner $!
echo -e "${WHITE}Done.${NC}"

# 4. Configs
echo -e "${CYAN}[3/5]${NC} Applying Glass/White configurations..."
(mkdir -p ~/.config && cp -rf configs/* ~/.config/ > /dev/null 2>&1) & spinner $!
echo -e "${WHITE}Done.${NC}"

# 5. System Tweaks
echo -e "${CYAN}[4/5]${NC} Applying system-wide optimizations..."
(
    # Permissions
    sudo usermod -aG video $USER || true
    chmod +x ~/.config/waybar/launch.sh
    chmod +x ~/.config/hypr/scripts/powermenu.sh
    
    # GTK Dark Theme
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    
    # Services
    systemctl --user enable --now pipewire pipewire-pulse wireplumber > /dev/null 2>&1 || true
) & spinner $!
echo -e "${WHITE}Done.${NC}"

# 6. Finalizing
echo -e "${CYAN}[5/5]${NC} Finalizing installation..."
sleep 1
echo -e ""
echo -e "  ${WHITE}╔══════════════════════════════════════════╗${NC}"
echo -e "  ${WHITE}║${NC}  ${MAGENTA}INSTALLATION COMPLETE!${NC}                  ${WHITE}║${NC}"
echo -e "  ${WHITE}║${NC}  ${WHITE}Please logout and login again.${NC}          ${WHITE}║${NC}"
echo -e "  ${WHITE}╚══════════════════════════════════════════╝${NC}"
echo -e ""
