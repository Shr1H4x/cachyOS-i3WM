#!/bin/bash

# =========================================
# PERFECT RICE BACKUP SCRIPT
# =========================================

BACKUP_ROOT="$HOME/dotfiles-backup"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_NAME="rice-$DATE"
BACKUP_DIR="$BACKUP_ROOT/$BACKUP_NAME"
ARCHIVE="$HOME/$BACKUP_NAME.tar.gz"

echo "========================================"
echo "Creating rice backup..."
echo "========================================"

mkdir -p "$BACKUP_DIR"

# =========================================
# SAFE COPY FUNCTION
# =========================================

copy_item() {
    SRC="$1"
    DEST="$2"

    if [ -e "$SRC" ]; then
        echo "[+] $SRC"

        mkdir -p "$DEST"

        cp -rf "$SRC" "$DEST/" 2>/dev/null
    else
        echo "[-] Missing: $SRC"
    fi
}

# =========================================
# CONFIGS
# =========================================

echo ""
echo "[CONFIGS]"

copy_item ~/.config/i3 "$BACKUP_DIR/.config"
copy_item ~/.config/polybar "$BACKUP_DIR/.config"
copy_item ~/.config/picom "$BACKUP_DIR/.config"
copy_item ~/.config/rofi "$BACKUP_DIR/.config"
copy_item ~/.config/dunst "$BACKUP_DIR/.config"

copy_item ~/.config/alacritty "$BACKUP_DIR/.config"
copy_item ~/.config/kitty "$BACKUP_DIR/.config"
copy_item ~/.config/fish "$BACKUP_DIR/.config"

copy_item ~/.config/ncmpcpp "$BACKUP_DIR/.config"
copy_item ~/.config/mpd "$BACKUP_DIR/.config"

copy_item ~/.config/gtk-3.0 "$BACKUP_DIR/.config"
copy_item ~/.config/gtk-4.0 "$BACKUP_DIR/.config"

# =========================================
# HOME FILES
# =========================================

echo ""
echo "[HOME FILES]"

copy_item ~/.bashrc "$BACKUP_DIR"
copy_item ~/.zshrc "$BACKUP_DIR"
copy_item ~/.xinitrc "$BACKUP_DIR"
copy_item ~/.Xresources "$BACKUP_DIR"

# =========================================
# THEMES / ICONS
# =========================================

echo ""
echo "[THEMES + ICONS]"

copy_item ~/.themes "$BACKUP_DIR"
copy_item ~/.icons "$BACKUP_DIR"

copy_item ~/.local/share/icons "$BACKUP_DIR/.local/share"

# =========================================
# FONTS
# =========================================

echo ""
echo "[FONTS]"

copy_item ~/.fonts "$BACKUP_DIR"
copy_item ~/.local/share/fonts "$BACKUP_DIR/.local/share"

# =========================================
# CUSTOM SCRIPTS
# =========================================

echo ""
echo "[SCRIPTS]"

copy_item ~/.scripts "$BACKUP_DIR"
copy_item ~/.local/bin "$BACKUP_DIR/.local"

# =========================================
# WALLPAPERS
# =========================================

echo ""
echo "[WALLPAPERS]"

copy_item ~/Pictures/wallpapers "$BACKUP_DIR/Pictures"
copy_item ~/Pictures/Wallpapers "$BACKUP_DIR/Pictures"

# =========================================
# PACKAGE LISTS
# =========================================

echo ""
echo "[PACKAGES]"

pacman -Qqe > "$BACKUP_DIR/pkglist.txt" 2>/dev/null
pacman -Qqm > "$BACKUP_DIR/aurlist.txt" 2>/dev/null

# =========================================
# SYSTEM INFO
# =========================================

echo ""
echo "[SYSTEM INFO]"

if command -v fastfetch &>/dev/null; then
    fastfetch > "$BACKUP_DIR/systeminfo.txt" 2>/dev/null
elif command -v neofetch &>/dev/null; then
    neofetch > "$BACKUP_DIR/systeminfo.txt" 2>/dev/null
fi

fc-list > "$BACKUP_DIR/fonts.txt" 2>/dev/null

# =========================================
# SCREENSHOT
# =========================================

echo ""
echo "[SCREENSHOT]"

mkdir -p "$BACKUP_DIR/screenshots"

if command -v scrot &>/dev/null; then
    scrot "$BACKUP_DIR/screenshots/rice.png" 2>/dev/null
fi

# =========================================
# CREATE ARCHIVE
# =========================================

echo ""
echo "Compressing backup..."

cd "$BACKUP_ROOT" || exit

tar -czf "$ARCHIVE" "$BACKUP_NAME"

# =========================================
# VERIFY
# =========================================

if [ -f "$ARCHIVE" ]; then

    echo ""
    echo "========================================"
    echo "Backup completed successfully!"
    echo "========================================"
    echo ""
    echo "$ARCHIVE"

else

    echo ""
    echo "========================================"
    echo "BACKUP FAILED!"
    echo "========================================"

fi

# =========================================
# CLEAN TEMP FILES
# =========================================

rm -rf "$BACKUP_DIR"