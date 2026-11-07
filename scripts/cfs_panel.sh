#!/bin/sh
# cfs_panel.sh - Install/remove CFS Panel for Mainsail (swilsonnc/K2-plus-cfs-panel)
SCRIPT_DIR=/mnt/UDISK/helper-script
. "$SCRIPT_DIR/scripts/system.sh"

MAINSAIL_DIR=/usr/share/mainsail
# Pinned commit (2026-08-10); bump deliberately after testing a newer one.
CFS_PANEL_URL=https://raw.githubusercontent.com/swilsonnc/K2-plus-cfs-panel/f42a5126c5c619c02350083895497b3c340541d5/cfs-panel.js

# Add (inject) or remove (strip) the panel's <script> tag in Mainsail's index.html.
# Editing the tag instead of restoring a backup keeps a newer Mainsail intact.
edit_index() {
    python3 - "$MAINSAIL_DIR/index.html" "$1" << 'PYEOF'
import sys
path, mode = sys.argv[1], sys.argv[2]
tag = '<script src="cfs-panel.js" defer></script>'
html = open(path, encoding='utf-8').read()
if mode == 'inject':
    if 'cfs-panel.js' in html:
        print('CFS panel already linked in index.html')
        sys.exit(0)
    anchor = '<div id="app"></div>'
    if anchor not in html:
        print('ERROR: <div id="app"></div> not found in index.html')
        sys.exit(1)
    html = html.replace(anchor, anchor + tag, 1)
else:
    # also the tag older versions of this script added
    for t in (tag, '\n    <script src="cfs-panel.js"></script>', '<script src="cfs-panel.js"></script>'):
        html = html.replace(t, '')
open(path, 'w', encoding='utf-8').write(html)
print('index.html updated (%s)' % mode)
PYEOF
}

install_cfs_panel() {
    echo ""
    log_info "Installing CFS Panel for Mainsail..."
    log_warn "This panel is written for the K2 Plus; test it on your K2 before relying on it."
    echo ""

    if [ ! -f "$MAINSAIL_DIR/index.html" ]; then
        log_error "Mainsail not found in $MAINSAIL_DIR. Install Mainsail first."
        return 1
    fi

    python3 -c "import urllib.request,sys; urllib.request.urlretrieve(sys.argv[1], sys.argv[2])" \
        "$CFS_PANEL_URL" /tmp/cfs-panel.js || { log_error "Downloading the CFS panel failed."; return 1; }
    mv /tmp/cfs-panel.js "$MAINSAIL_DIR/cfs-panel.js"

    edit_index inject || return 1
    # Static files: a browser refresh is enough, no Klipper/Moonraker restart.
    mark_installed "cfs_panel"
    log_success "CFS Panel installed. Refresh Mainsail in your browser."
    echo ""
}

remove_cfs_panel() {
    if ! is_installed "cfs_panel"; then
        log_info "CFS Panel for Mainsail is not installed."
        return 0
    fi

    echo -e "${YELLOW}WARNING: This removes the CFS Panel for Mainsail.${NC}"
    printf "Are you sure? [y/n]: "
    read confirm
    [ "$confirm" != "y" ] && [ "$confirm" != "Y" ] && { log_info "Cancelled."; return 0; }

    [ -f "$MAINSAIL_DIR/index.html" ] && edit_index strip
    # index.html.bak came from older versions of this script and may predate a Mainsail update
    rm -f "$MAINSAIL_DIR/cfs-panel.js" "$MAINSAIL_DIR/index.html.bak"
    mark_removed "cfs_panel"
    log_success "CFS Panel removed. Refresh Mainsail in your browser."
    echo ""
}

case "$1" in
    install) install_cfs_panel ;;
    remove)  remove_cfs_panel ;;
    # mainsail.sh: relink after a Mainsail update replaced index.html
    inject)  is_installed "cfs_panel" && edit_index inject ;;
    *)       echo "Usage: $0 [install|remove|inject]" ;;
esac
