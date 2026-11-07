#!/bin/sh
# kamp.sh - KAMP pointer (use KAMP-K2) and removal of older upstream KAMP installs
SCRIPT_DIR=/mnt/UDISK/helper-script
. "$SCRIPT_DIR/scripts/system.sh"
KAMP_DIR=$CONFIG_DIR/KAMP

install_kamp() {
    # Upstream KAMP does not work on the K2's stock firmware: prtouch_v3_wrapper.so
    # takes over BED_MESH_CALIBRATE, ignores MESH_MIN/MESH_MAX (crashes when they
    # are passed) and master-server runs its own full mesh anyway.
    echo ""
    log_warn "Upstream KAMP does not work on the K2 stock firmware, so it is no longer installed here."
    log_info "Use KAMP-K2 instead, installed from your PC: https://github.com/grant0013/KAMP-K2"
    log_info "Note: an adaptive mesh only covers the objects. A prime tower outside them"
    log_info "is printed off-mesh; the stock full-bed mesh always covers it."
    echo ""
}

remove_kamp() {
    if ! is_installed "kamp"; then
        log_info "Kamp is not installed."
        return 0
    fi

    echo -e "${YELLOW}WARNING: This will remove KAMP.${NC}"
    printf "Are you sure? [y/n]: "
    read confirm
    [ "$confirm" != "y" ] && [ "$confirm" != "Y" ] && { log_info "Cancelled."; return 0; }
    echo ""
    log_info "Removing KAMP..."
    remove_include_from_printer_cfg "KAMP/KAMP_Settings.cfg"
    rm -rf "$KAMP_DIR"
    restart_klipper force
    mark_removed "kamp"
    log_success "KAMP removed."
    echo ""
}

case "$1" in
    install) install_kamp ;;
    remove)  remove_kamp ;;
    *)       echo "Usage: $0 [install|remove]" ;;
esac
