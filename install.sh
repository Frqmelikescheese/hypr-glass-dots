#!/bin/bash

# --- frqme-glass-rice Installer (Aesthetic Edition) ---

# Colors
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Identify the real user if run via sudo
if [ "$EUID" -eq 0 ] && [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
    REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    REAL_USER="$USER"
    REAL_HOME="$HOME"
fi

# Helper for animations
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
    wait "$pid"
    return $?
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
echo -e "${CYAN}[*]${NC} Installing for user: ${WHITE}$REAL_USER${NC} (Home: $REAL_HOME)"
echo ""

# 1. Check Root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[!]${NC} Please run with sudo or as root (to install packages)"
  exit 1
fi

# 2. Dependencies
echo -ne "${CYAN}[1/5]${NC} Installing system dependencies..."
DEPS=(
    hyprland waybar rofi kitty thunar fastfetch cava
    hyprpaper swaybg dunst network-manager-applet blueman
    pavucontrol brightnessctl pipewire-pulse wireplumber
    ttf-jetbrains-mono-nerd ttf-font-awesome
    nwg-look arc-gtk-theme papirus-icon-theme
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
    qt5-wayland qt6-wayland cliphist rofi-calc wl-clipboard
)

# Use a log file for errors
LOG_FILE="/tmp/glass-rice-install.log"
: > "$LOG_FILE"

# Check for pacman
if ! command -v pacman &> /dev/null; then
    echo -e "${RED}Error.${NC} This script requires 'pacman' (Arch Linux)."
    echo "Please install dependencies manually: ${DEPS[*]}"
    exit 1
fi

# Sync and install
(
    pacman -Syy --noconfirm >> "$LOG_FILE" 2>&1
    for pkg in "${DEPS[@]}"; do
        if pacman -Q "$pkg" &>/dev/null; then
            echo "Package $pkg is already installed. Skipping..." >> "$LOG_FILE" 2>&1
        else
            echo "Installing $pkg..." >> "$LOG_FILE" 2>&1
            if ! pacman -S --needed --noconfirm "$pkg" >> "$LOG_FILE" 2>&1; then
                echo "Error: Failed to install $pkg" >> "$LOG_FILE" 2>&1
            fi
        fi
    done
) & 
if ! spinner $!; then
    echo -e "${RED}Warning.${NC} Some packages could not be installed. Check $LOG_FILE"
fi
echo -e "${WHITE}Done.${NC}"

# 3. Backup
echo -ne "${CYAN}[2/5]${NC} Backing up existing config..."
BACKUP_DIR="$REAL_HOME/.config.backup-$(date +%s)"
(
    mkdir -p "$BACKUP_DIR"
    if [ -d "$REAL_HOME/.config" ]; then
        # Copy to backup directory, avoid infinite recursion if backup is in .config
        cp -rf "$REAL_HOME/.config/"* "$BACKUP_DIR/" 2>/dev/null || true
    fi
) >> "$LOG_FILE" 2>&1 & 
spinner $!
echo -e "${WHITE}Done.${NC}"

# 4. Configs
echo -ne "${CYAN}[3/5]${NC} Applying Glass/White configurations..."
if [ ! -d "configs" ]; then
    echo -e "${RED}Error.${NC} 'configs/' directory not found in current path."
    exit 1
fi

(
    mkdir -p "$REAL_HOME/.config"
    # Using -v to see what's being copied in the log
    cp -rv configs/* "$REAL_HOME/.config/"
    chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.config"
) >> "$LOG_FILE" 2>&1 &
if ! spinner $!; then
    echo -e "${RED}Error copying files.${NC} Check $LOG_FILE"
    exit 1
fi
echo -e "${WHITE}Done.${NC}"

# 5. System Tweaks
echo -ne "${CYAN}[4/5]${NC} Applying system-wide optimizations..."
(
    # Permissions for scripts
    find "$REAL_HOME/.config/waybar" -type f -name "*.sh" -exec chmod +x {} +
    find "$REAL_HOME/.config/hypr/scripts" -type f -name "*.sh" -exec chmod +x {} +
    
    # Ownership
    chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.config"

    # Group additions
    usermod -aG video "$REAL_USER" || true
    
    # Services
    # Attempting to enable user services as the real user
    # Note: this might fail in a non-interactive/no-dbus environment, which is fine
    sudo -u "$REAL_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $REAL_USER)/bus" systemctl --user enable --now pipewire pipewire-pulse wireplumber > /dev/null 2>&1 || true

    # Shell Alias
    echo "alias pipes='pipes.sh -c 6'" >> "$REAL_HOME/.bashrc"
) >> "$LOG_FILE" 2>&1 &
spinner $!
echo -e "${WHITE}Done.${NC}"

# 6. Finalizing
echo -ne "${CYAN}[5/5]${NC} Finalizing installation..."
sleep 1
echo -e "${WHITE}Done.${NC}"
echo -e ""
echo -e "  ${WHITE}╔══════════════════════════════════════════╗${NC}"
echo -e "  ${WHITE}║${NC}  ${MAGENTA}INSTALLATION COMPLETE!${NC}                  ${WHITE}║${NC}"
echo -e "  ${WHITE}║${NC}  ${WHITE}Please logout and login again.${NC}          ${WHITE}║${NC}"
echo -e "  ${WHITE}╚══════════════════════════════════════════╝${NC}"
echo -e ""
