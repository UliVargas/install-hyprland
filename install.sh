#!/bin/bash
set -eEo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()   { echo -e "${CYAN}>>> $1${NC}"; }
ok()    { echo -e "${GREEN}  ✓ $1${NC}"; }
warn()  { echo -e "${YELLOW}  ⚠ $1${NC}"; }
phase() { echo; echo -e "${GREEN}=== $1 ===${NC}"; echo; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMARCHY_SRC="$SCRIPT_DIR/omarchy"
OMARCHY_DST="$HOME/.local/share/omarchy"
BACKUP_DIR="$SCRIPT_DIR/backup"

# ============================================================
# STAGE 0: Install Omarchy to ~/.local/share/omarchy
# ============================================================
phase "Stage 0: Installing Omarchy"

if [[ ! -d "$OMARCHY_SRC" ]]; then
  echo -e "${RED}Error: omarchy/ directory not found in this folder${NC}"
  exit 1
fi

mkdir -p "$HOME/.local/share"
if [[ -d "$OMARCHY_DST" ]]; then
  log "Omarchy exists — patching install scripts for ARM"
  # Always overwrite patched files even if omarchy exists
  cp -f "$OMARCHY_SRC/install/preflight/guard.sh" "$OMARCHY_DST/install/preflight/"
  cp -f "$OMARCHY_SRC/install/preflight/pacman.sh" "$OMARCHY_DST/install/preflight/"
  cp -f "$OMARCHY_SRC/install/preflight/all.sh" "$OMARCHY_DST/install/preflight/"
  cp -f "$OMARCHY_SRC/install/login/all.sh" "$OMARCHY_DST/install/login/"
  cp -f "$OMARCHY_SRC/install/packaging/all.sh" "$OMARCHY_DST/install/packaging/"
  cp -f "$OMARCHY_SRC/install/config/all.sh" "$OMARCHY_DST/install/config/"
  cp -f "$OMARCHY_SRC/install/config/config.sh" "$OMARCHY_DST/install/config/"
  cp -f "$OMARCHY_SRC/install/post-install/pacman.sh" "$OMARCHY_DST/install/post-install/"
  cp -f "$OMARCHY_SRC/install/omarchy-base.packages" "$OMARCHY_DST/install/"
  cp -f "$OMARCHY_SRC/install/omarchy-other.packages" "$OMARCHY_DST/install/"
  ok "ARM patches applied"
else
  log "Copying Omarchy to $OMARCHY_DST"
  cp -r "$OMARCHY_SRC" "$OMARCHY_DST"
  ok "Omarchy installed"
fi

export OMARCHY_PATH="$OMARCHY_DST"
export OMARCHY_INSTALL="$OMARCHY_DST/install"
export OMARCHY_INSTALL_LOG_FILE="/var/log/omarchy-install.log"
export PATH="$OMARCHY_DST/bin:$PATH"

ok "Omarchy installed"

# ============================================================
# STAGE 1: Omarchy Base Install (already ARM-patched)
# ============================================================
phase "Stage 1: Omarchy Base Install"

# Resolve gnome-themes conflict before base install
if pacman -Q gnome-themes-standard &>/dev/null; then
  warn "gnome-themes-standard detected — removing for gnome-themes-extra"
  sudo pacman -R --noconfirm gnome-themes-standard 2>/dev/null || true
  ok "gnome-themes-standard removed"
fi

source "$OMARCHY_INSTALL/helpers/all.sh"
source "$OMARCHY_INSTALL/preflight/all.sh"
source "$OMARCHY_INSTALL/packaging/all.sh"
source "$OMARCHY_INSTALL/config/all.sh"
source "$OMARCHY_INSTALL/login/all.sh"
source "$OMARCHY_INSTALL/post-install/all.sh"

ok "Omarchy base install complete"

# ============================================================
# STAGE 1.5: Manual AUR packages (not in pacman or outdated)
# ============================================================
phase "Stage 1.5: Installing manual AUR packages"

# yay — can't install itself, check if present
if ! command -v yay &>/dev/null; then
  log "Installing yay from AUR..."
  TMPDIR=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$TMPDIR/yay"
  cd "$TMPDIR/yay" && makepkg -si --noconfirm
  cd - && rm -rf "$TMPDIR"
  ok "yay installed"
else
  ok "yay already installed"
fi

# xdg-terminal-exec-git (regular package is outdated)
if ! pacman -Q xdg-terminal-exec-git &>/dev/null; then
  yay -S --noconfirm xdg-terminal-exec-git 2>/dev/null && ok "xdg-terminal-exec-git installed" || warn "xdg-terminal-exec-git failed"
else
  ok "xdg-terminal-exec-git already installed"
fi

# yaru-icon-theme (AUR only)
if ! pacman -Q yaru-icon-theme &>/dev/null; then
  yay -S --noconfirm yaru-icon-theme 2>/dev/null && ok "yaru-icon-theme installed" || warn "yaru-icon-theme failed"
else
  ok "yaru-icon-theme already installed"
fi

# ============================================================
# STAGE 2: Prerequisites
# ============================================================
phase "Stage 2: Installing Prerequisites"

sudo pacman -Syu --needed --noconfirm \
  base-devel git gum yay wget curl sudo \
  hyprland hyprlock hypridle hyprsunset \
  sddm waybar mako \
  alacritty foot \
  btop starship fastfetch \
  chromium nautilus gnome-keyring \
  wireplumber pipewire pipewire-pulse pipewire-alsa \
  networkmanager iwd \
  noto-fonts noto-fonts-cjk noto-fonts-emoji \
  ttf-jetbrains-mono-nerd \
  wl-clipboard slurp grim \
  docker docker-compose \
  ufw \
  tmux lazygit ripgrep fd fzf bat eza zoxide \
  qt5-wayland qt6-wayland \
  xdg-desktop-portal-gtk xdg-desktop-portal-hyprland \
  xdg-terminal-exec \
  playerctl pamixer \
  polkit-gnome \
  gvfs-mtp gvfs-nfs gvfs-smb \
  imagemagick \
  mpv imv \
  evince \
  xdg-user-dirs \
  xorg-xcompose \
  man-db less tree \
  python-gobject \
  ruby \
  clang llvm \
  dosfstools exfatprogs \
  inetutils whois \
  unzip \
  bash-completion \
  swayosd

ok "Prerequisites installed"

# ============================================================
# STAGE 3: Optional AUR
# ============================================================
phase "Stage 3: Installing Optional AUR Packages"

for pkg in 1password-cli spotify typora localsend signal-desktop obsidian \
  obs-studio kdenlive pinta xournalpp satty gpu-screen-recorder \
  bluetui cliamp impala tobi-try wiremix asdcontrol \
  kernel-modules-hook hyprland-guiutils hyprland-preview-share-picker \
  omarchy-nvim omarchy-walker; do
  if pacman -Q "$pkg" &>/dev/null; then
    ok "$pkg (installed)"
  elif yay -S --noconfirm "$pkg" 2>/dev/null; then
    ok "$pkg installed"
  else
    warn "$pkg failed (not available for ARM?)"
  fi
done

# ============================================================
# STAGE 4: SDDM + Login
# ============================================================
phase "Stage 4: Configuring SDDM"

command -v omarchy-refresh-sddm &>/dev/null && omarchy-refresh-sddm

sudo mkdir -p /usr/local/share/wayland-sessions
[[ -f "$OMARCHY_DST/default/wayland-sessions/omarchy.desktop" ]] && \
  sudo cp "$OMARCHY_DST/default/wayland-sessions/omarchy.desktop" /usr/local/share/wayland-sessions/
[[ -f "$OMARCHY_DST/default/sddm/hyprland.conf" ]] && \
  sudo cp "$OMARCHY_DST/default/sddm/hyprland.conf" /usr/share/sddm/

sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/10-wayland.conf >/dev/null <<EOF
[General]
DisplayServer=wayland

[Wayland]
CompositorCommand=start-hyprland -- --config /usr/share/sddm/hyprland.conf
EOF

if [[ ! -f /etc/sddm.conf.d/autologin.conf ]]; then
  sudo tee /etc/sddm.conf.d/autologin.conf >/dev/null <<EOF
[Autologin]
User=$USER
Session=omarchy

[Theme]
Current=omarchy
EOF
else
  sudo sed -i 's/^Session=hyprland-uwsm$/Session=omarchy/' /etc/sddm.conf.d/autologin.conf
fi

sudo sed -i '/-auth.*pam_gnome_keyring\.so/d' /etc/pam.d/sddm 2>/dev/null || true
sudo sed -i '/-password.*pam_gnome_keyring\.so/d' /etc/pam.d/sddm 2>/dev/null || true

# Default keyring
mkdir -p "$HOME/.local/share/keyrings"
cat > "$HOME/.local/share/keyrings/Default_keyring.keyring" <<EOF
[keyring]
display-name=Default keyring
ctime=$(date +%s)
mtime=0
lock-on-idle=false
lock-after=false
EOF
echo "Default_keyring" > "$HOME/.local/share/keyrings/default"
chmod 700 "$HOME/.local/share/keyrings"
chmod 600 "$HOME/.local/share/keyrings/Default_keyring.keyring"
chmod 644 "$HOME/.local/share/keyrings/default"

# Plymouth
if command -v plymouth-set-default-theme &>/dev/null; then
  [[ "$(plymouth-set-default-theme)" != "omarchy" ]] && {
    sudo cp -r "$OMARCHY_DST/default/plymouth" /usr/share/plymouth/themes/omarchy/ 2>/dev/null || true
    sudo plymouth-set-default-theme omarchy 2>/dev/null || true
  }
fi

sudo systemctl enable sddm

ok "SDDM configured"

# ============================================================
# STAGE 5: Enable Services
# ============================================================
phase "Stage 5: Enabling Services"

for svc in sddm docker.socket NetworkManager iwd ufw power-profiles-daemon avahi-daemon cups cups-browsed; do
  sudo systemctl enable "$svc" 2>/dev/null || true
done

ok "Services enabled"

# ============================================================
# STAGE 6: Theme + Restore Configs
# ============================================================
phase "Stage 6: Applying Theme and Restoring Configs"

command -v omarchy &>/dev/null && omarchy theme set "Catppuccin" 2>/dev/null || true

mkdir -p ~/.config/btop/themes
ln -snf ~/.config/omarchy/current/theme/btop.theme ~/.config/btop/themes/current.theme 2>/dev/null || true
mkdir -p ~/.config/mako
ln -snf ~/.config/omarchy/current/theme/mako.ini ~/.config/mako/config 2>/dev/null || true

if [[ -d "$BACKUP_DIR" ]]; then
  for dir in hypr waybar walker swayosd alacritty foot kitty ghostty btop fastfetch git; do
    [[ -d "$BACKUP_DIR/$dir" ]] && cp "$BACKUP_DIR/$dir/"* "$HOME/.config/$dir/" 2>/dev/null && ok "$dir configs restored"
  done
  [[ -d "$BACKUP_DIR/mako" ]] && cp "$BACKUP_DIR/mako/"* "$HOME/.config/mako/" 2>/dev/null && ok "mako config restored"
  [[ -f "$BACKUP_DIR/starship.toml" ]] && cp "$BACKUP_DIR/starship.toml" ~/.config/ && ok "starship restored"
  [[ -d "$BACKUP_DIR/omarchy" ]] && cp -r "$BACKUP_DIR/omarchy/"* ~/.config/omarchy/ 2>/dev/null && ok "omarchy theme restored"
fi

# ============================================================
# STAGE 7: First-Run Tasks
# ============================================================
phase "Stage 7: First-Run Tasks"

# Fix Hyprland ARM: create missing shaders directory
sudo mkdir -p /usr/share/hypr/shaders

sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf 2>/dev/null || true
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark" 2>/dev/null || true
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme "Yaru-blue" 2>/dev/null || true
sudo gtk-update-icon-cache /usr/share/icons/Yaru 2>/dev/null || true
gsettings set org.gnome.desktop.interface gtk-enable-primary-paste true 2>/dev/null || true

systemctl --user daemon-reload
systemctl --user enable --now swayosd-server.service 2>/dev/null || true

command -v omarchy-battery-present &>/dev/null && omarchy-battery-present && \
  { powerprofilesctl set balanced 2>/dev/null || true; systemctl --user enable --now omarchy-battery-monitor.service 2>/dev/null || true; } || \
  powerprofilesctl set performance 2>/dev/null || true

sudo ufw default deny incoming 2>/dev/null || true
sudo ufw default allow outgoing 2>/dev/null || true
sudo ufw allow 53317/udp 2>/dev/null || true
sudo ufw allow 53317/tcp 2>/dev/null || true
sudo ufw --force enable 2>/dev/null || true
command -v ufw-docker &>/dev/null && sudo ufw-docker install 2>/dev/null || true

command -v notify-send &>/dev/null && notify-send "Omarchy ARM" "Installation complete!" -u critical 2>/dev/null || true

ok "First-run complete"

# ============================================================
# DONE
# ============================================================
echo
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Omarchy ARM — Installation Complete!     ${NC}"
echo -e "${GREEN}============================================${NC}"
echo
echo "Reboot: sudo reboot"
echo
