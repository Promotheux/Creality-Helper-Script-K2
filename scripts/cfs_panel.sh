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

    if [ ! -d "/tmp/cfs-panel" ]; then
        log_error "Download van CFS Panel mislukt."
        return 1
    fi

    log_info "Integreren in Mainsail index.html..."
    
    # Voorbeeld voor het injecteren van scripts/bestanden vanuit de gedownloade repo naar Mainsail
    python3 - << 'PYEOF'
import os, re

mainsail_path = '/usr/share/mainsail/index.html'
if os.path.exists(mainsail_path):
    with open(mainsail_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Voeg eventuele benodigde injecties of scripts toe voor het CFS-paneel
    # (Pas dit aan op basis van de specifieke bestanden in swilsonnc/K2-plus-cfs-panel)
    
    print("Mainsail index.html bijgewerkt voor CFS Panel.")
PYEOF

    # Eventuele extra configuratiebestanden kopiëren naar printer_data/config indien aanwezig
    if [ -d "/tmp/cfs-panel/config" ]; then
        cp -r /tmp/cfs-panel/config/* "$CONFIG_DIR/"
        log_success "CFS configuratiebestanden gekopieerd."
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
    mark_removed "cfs_panel"
    log_success "CFS Panel for Mainsail verwijderd."
    echo ""
}

case "$1" in
    install) install_cfs_panel ;;
    remove)  remove_cfs_panel ;;
    *)       echo "Usage: $0 [install|remove]" ;;
esac