#!/bin/bash

# =========================================
# PERFECT RICE RESTORE SCRIPT
# =========================================

ARCHIVE=$(find "$HOME" -maxdepth 1 -name "rice-*.tar.gz" | sort | tail -n 1)

if [ -z "$ARCHIVE" ]; then
    echo "========================================"
    echo "No rice backup archive found!"
    echo "========================================"
    exit 1
fi

RESTORE_DIR="$HOME/restore-rice-temp"

echo "========================================"
echo "Restoring rice setup..."
echo "========================================"

echo ""
echo "Using backup:"
echo "$ARCHIVE"

# =========================================
# CLEAN TEMP
# =========================================

rm -rf "$RESTORE_DIR"
mkdir -p "$RESTORE_DIR"

# =========================================
# EXTRACT
# =========================================

echo ""
echo "Extracting backup..."

tar -xzf "$ARCHIVE" -C "$RESTORE_DIR"

RESTORE_PATH=$(find "$RESTORE_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)

# =========================================
# REMOVE OLD CONFIGS
# =========================================

echo ""
echo "Cleaning old configs..."

rm -rf ~/.config/i3
rm -rf ~/.config/polybar
rm -rf ~/.config/picom
rm -rf ~/.config/rofi
rm -rf ~/.config/dunst

rm -rf ~/.config/alacritty
rm -rf ~/.config/kitty
rm -rf ~/.config/fish

rm -rf ~/.config/ncmpcpp
rm -rf ~/.config/mpd

rm -rf ~/.config/gtk-3.0
rm -rf ~/.config/gtk-4.0

rm -rf ~/.themes
rm -rf ~/.icons
rm -rf ~/.fonts

rm -rf ~/.local/share/icons
rm -rf ~/.local/share/fonts

rm -rf ~/.scripts
rm -rf ~/.local/bin

rm -rf ~/Pictures/wallpapers
rm -rf ~/Pictures/Wallpapers

# =========================================
# RESTORE CONFIGS
# =========================================

echo ""
echo "Restoring configs..."

mkdir -p ~/.config

if [ -d "$RESTORE_PATH/.config" ]; then
    cp -rf "$RESTORE_PATH/.config/"* ~/.config/
fi

# =========================================
# RESTORE HOME FILES
# =========================================

echo ""
echo "Restoring home files..."

cp -rf "$RESTORE_PATH/.bashrc" ~/ 2>/dev/null
cp -rf "$RESTORE_PATH/.zshrc" ~/ 2>/dev/null
cp -rf "$RESTORE_PATH/.xinitrc" ~/ 2>/dev/null
cp -rf "$RESTORE_PATH/.Xresources" ~/ 2>/dev/null

# =========================================
# THEMES / ICONS
# =========================================

echo ""
echo "Restoring themes and icons..."

cp -rf "$RESTORE_PATH/.themes" ~/ 2>/dev/null
cp -rf "$RESTORE_PATH/.icons" ~/ 2>/dev/null

mkdir -p ~/.local/share

if [ -d "$RESTORE_PATH/.local/share/icons" ]; then
    cp -rf "$RESTORE_PATH/.local/share/icons" ~/.local/share/
fi

# =========================================
# FONTS
# =========================================

echo ""
echo "Restoring fonts..."

mkdir -p ~/.local/share

cp -rf "$RESTORE_PATH/.fonts" ~/ 2>/dev/null

if [ -d "$RESTORE_PATH/.local/share/fonts" ]; then
    cp -rf "$RESTORE_PATH/.local/share/fonts" ~/.local/share/
fi

fc-cache -fv >/dev/null 2>&1

# =========================================
# CUSTOM SCRIPTS
# =========================================

echo ""
echo "Restoring scripts..."

cp -rf "$RESTORE_PATH/.scripts" ~/ 2>/dev/null

mkdir -p ~/.local

if [ -d "$RESTORE_PATH/.local/bin" ]; then
    cp -rf "$RESTORE_PATH/.local/bin" ~/.local/
fi

chmod +x ~/.scripts/* 2>/dev/null
chmod +x ~/.local/bin/* 2>/dev/null

# =========================================
# WALLPAPERS
# =========================================

echo ""
echo "Restoring wallpapers..."

mkdir -p ~/Pictures

if [ -d "$RESTORE_PATH/Pictures" ]; then
    cp -rf "$RESTORE_PATH/Pictures/"* ~/Pictures/
fi

# =========================================
# INSTALL PACKAGES
# =========================================

echo ""
echo "Installing packages..."

if [ -f "$RESTORE_PATH/pkglist.txt" ]; then

    sudo pacman -Syu --noconfirm

    sudo pacman -S --needed --noconfirm \
        $(cat "$RESTORE_PATH/pkglist.txt")

fi

# =========================================
# INSTALL YAY
# =========================================

if [ -f "$RESTORE_PATH/aurlist.txt" ]; then

    if ! command -v yay &>/dev/null; then

        echo ""
        echo "Installing yay..."

        sudo pacman -S --needed --noconfirm git base-devel

        git clone https://aur.archlinux.org/yay.git /tmp/yay

        cd /tmp/yay || exit

        makepkg -si --noconfirm

    fi

    echo ""
    echo "Installing AUR packages..."

    yay -S --needed --noconfirm \
        $(cat "$RESTORE_PATH/aurlist.txt")

fi

# =========================================
# ENABLE SERVICES
# =========================================

echo ""
echo "Enabling services..."

systemctl --user enable mpd.service 2>/dev/null
systemctl --user restart mpd.service 2>/dev/null

sudo systemctl enable NetworkManager.service 2>/dev/null

# =========================================
# CLEANUP
# =========================================

echo ""
echo "Cleaning temporary files..."

rm -rf "$RESTORE_DIR"

# =========================================
# DONE
# =========================================

echo ""
echo "========================================"
echo "Rice restored successfully!"
echo "========================================"
echo ""
echo "Recommended:"
echo "1. Reboot system"
echo "2. Log into i3"
echo "3. Run: polybar-msg cmd restart"
echo ""