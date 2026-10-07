#!/bin/sh
# cfs_panel.sh - Install/remove CFS Panel for Mainsail (swilsonnc/K2-plus-cfs-panel)
SCRIPT_DIR=/mnt/UDISK/helper-script
. "$SCRIPT_DIR/scripts/system.sh"

MAINSAIL_DIR=/usr/share/mainsail

install_cfs_panel() {
    echo ""
    log_info "Installing CFS Panel for Mainsail..."
    echo ""

    if [ ! -d "$MAINSAIL_DIR" ] || [ ! -f "$MAINSAIL_DIR/index.html" ]; then
        log_error "Mainsail is niet gevonden in $MAINSAIL_DIR. Installeer eerst Mainsail."
        return 1
    fi

    # Download de repo tijdelijk
    rm -rf /tmp/cfs-panel
    if command -v git >/dev/null 2>&1; then
        git clone https://github.com/swilsonnc/K2-plus-cfs-panel.git /tmp/cfs-panel
    else
        python3 -c "
import urllib.request, zipfile, os, glob, shutil
url = 'https://github.com/swilsonnc/K2-plus-cfs-panel/archive/refs/heads/main.zip'
urllib.request.urlretrieve(url, '/tmp/cfs_panel.zip')
os.makedirs('/tmp/cfs-panel', exist_ok=True)
with zipfile.ZipFile('/tmp/cfs_panel.zip', 'r') as z:
    z.extractall('/tmp/cfs_panel_extract/')
src = glob.glob('/tmp/cfs_panel_extract/*')[0]
shutil.copytree(src, '/tmp/cfs-panel', dirs_exist_ok=True)
"
    fi

    if [ ! -d "/tmp/cfs-panel" ]; then
        log_error "Download van CFS Panel mislukt."
        return 1
    fi

    log_info "Bestanden kopiëren naar Mainsail..."
    
    # Zoek en kopieer cfs-panel.js naar /usr/share/mainsail/
    if [ -f "/tmp/cfs-panel/cfs-panel.js" ]; then
        cp /tmp/cfs-panel/cfs-panel.js "$MAINSAIL_DIR/"
        log_success "cfs-panel.js geplaatst in $MAINSAIL_DIR"
    else
        # Zoek eventueel dieper in de mappenstructuur als hij ergens anders staat
        find /tmp/cfs-panel -name "cfs-panel.js" -exec cp {} "$MAINSAIL_DIR/" \;
        log_success "cfs-panel.js gekopieerd."
    fi

    # Backup en patch index.html
    if [ -f "$MAINSAIL_DIR/index.html" ]; then
        if [ ! -f "$MAINSAIL_DIR/index.html.bak" ]; then
            cp "$MAINSAIL_DIR/index.html" "$MAINSAIL_DIR/index.html.bak"
            log_success "Backup gemaakt van Mainsail index.html"
        fi

        python3 - << 'PYEOF'
import os

index_path = '/usr/share/mainsail/index.html'
with open(index_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Controleer of het script er al in staat om dubbele injectie te voorkomen
if 'cfs-panel.js' not in content:
    target = '<div id="app"></div>'
    # Voeg het script toe onder <div id="app"></div> (of direct erachter met een script-tag)
    injection = '<div id="app"></div>\n    <script src="cfs-panel.js"></script>'
    if target in content:
        content = content.replace(target, injection)
        with open(index_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print("cfs-panel.js succesvol gekoppeld in index.html")
    else:
        print("Waarschuwing: <div id=\"app\"></div> niet gevonden in index.html")
else:
    print("cfs-panel.js is reeds aanwezig in index.html")
PYEOF
    fi

    rm -rf /tmp/cfs-panel /tmp/cfs_panel.zip /tmp/cfs_panel_extract

    restart_moonraker force
    restart_klipper force
    mark_installed "cfs_panel"
    log_success "CFS Panel for Mainsail succesvol geïnstalleerd!"
    echo ""
}

remove_cfs_panel() {
    if ! is_installed "cfs_panel"; then
        log_info "CFS Panel for Mainsail is niet geïnstalleerd."
        return 0
    fi

    echo -e "${YELLOW}WARNING: Dit verwijdert het CFS Panel voor Mainsail.${NC}"
    printf "Weet je dit zeker? [y/n]: "
    read confirm
    [ "$confirm" != "y" ] && [ "$confirm" != "Y" ] && { log_info "Geannuleerd."; return 0; }

    log_info "CFS Panel verwijderen..."
    rm -f "$MAINSAIL_DIR/cfs-panel.js"

    # Herstel index.html vanuit backup indien aanwezig
    if [ -f "$MAINSAIL_DIR/index.html.bak" ]; then
        cp "$MAINSAIL_DIR/index.html.bak" "$MAINSAIL_DIR/index.html"
        rm -f "$MAINSAIL_DIR/index.html.bak"
        log_success "Originele index.html hersteld."
    fi

    restart_moonraker force
    restart_klipper force
    mark_removed "cfs_panel"
    log_success "CFS Panel for Mainsail verwijderd."
    echo ""
}

case "$1" in
    install) install_cfs_panel ;;
    remove)  remove_cfs_panel ;;
    *)       echo "Usage: $0 [install|remove]" ;;
esac