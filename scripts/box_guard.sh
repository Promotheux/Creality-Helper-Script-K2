#!/bin/sh
# box_guard.sh - Guard CFS commands against empty ADDR/NUM (Creality key171/key60 shutdown)
# Adapted from opoeta/k2-improvements features/macros/box_guard (GPLv3).
SCRIPT_DIR=/mnt/UDISK/helper-script
. "$SCRIPT_DIR/scripts/system.sh"

GUARD_CFG=$CONFIG_DIR/box_guard.cfg

install_box_guard() {
    echo ""
    log_info "Installing CFS box guard..."
    cat > "$GUARD_CFG" << 'EOF'
# box_guard.cfg - installed by the helper script, remove it from the menu.
#
# Creality's BOX_INFO_REFRESH sometimes sends BOX_SET_PRE_LOADING and
# BOX_GET_RFID with empty ADDR=/NUM=. The compiled CFS module then crashes
# and Klipper shuts down (key171 "Unable to parse", key60 "Internal error").
# These wrappers skip such calls and pass every normal call through unchanged.

[gcode_macro BOX_SET_PRE_LOADING]
rename_existing: _OG_BOX_SET_PRE_LOADING
description: Skips calls with empty ADDR/NUM (Creality key171/key60 bug)
gcode:
  {% if params.ADDR|default("")|trim != "" and params.NUM|default("")|trim != "" %}
    _OG_BOX_SET_PRE_LOADING {rawparams}
  {% else %}
    {action_respond_info("BOX_SET_PRE_LOADING skipped: empty ADDR/NUM (key171/key60 avoided)")}
  {% endif %}

[gcode_macro BOX_GET_RFID]
rename_existing: _OG_BOX_GET_RFID
description: Skips calls with empty ADDR/NUM (Creality key171/key60 bug)
gcode:
  {% if params.ADDR|default("")|trim != "" and params.NUM|default("")|trim != "" %}
    _OG_BOX_GET_RFID {rawparams}
  {% else %}
    {action_respond_info("BOX_GET_RFID skipped: empty ADDR/NUM (key171/key60 avoided)")}
  {% endif %}
EOF
    add_include_to_printer_cfg "box_guard.cfg"
    restart_klipper force
    mark_installed "box_guard"
    log_success "CFS box guard installed."
    echo ""
}

remove_box_guard() {
    if ! is_installed "box_guard"; then
        log_info "CFS box guard is not installed."
        return 0
    fi
    remove_include_from_printer_cfg "box_guard.cfg"
    rm -f "$GUARD_CFG"
    restart_klipper force
    mark_removed "box_guard"
    log_success "CFS box guard removed."
    echo ""
}

case "$1" in
    install) install_box_guard ;;
    remove)  remove_box_guard ;;
    *)       echo "Usage: $0 [install|remove]" ;;
esac
