#!/bin/sh
# patches.sh - DXC-2 extruder patches for the K2 stock configs (apply/undo, reapplied at boot)
SCRIPT_DIR=/mnt/UDISK/helper-script
. "$SCRIPT_DIR/scripts/system.sh"

MACRO_CFG="$CONFIG_DIR/gcode_macro.cfg"
BOX_CFG="$CONFIG_DIR/box.cfg"
# Only touch the retract macro (with or without the stock "_" prefix that
# patch_stock_configs strips), never other macros with the same G-code line.
RETRUDE_SECTION='/^\[gcode_macro _\{0,1\}QUIT_MATERIAL_RETRUDE_MATERIAL\]/,/^\[/'

# $1/$2: retract length from/to in the macro, $3/$4: Tn_retrude from/to in box.cfg
set_dxc_values() {
    if [ -f "$MACRO_CFG" ]; then
        sed -i "$RETRUDE_SECTION s/G0 E$1 F360/G0 E$2 F360/" "$MACRO_CFG"
        if sed -n "$RETRUDE_SECTION p" "$MACRO_CFG" | grep -q "G0 E$2 F360"; then
            log_success "QUIT_MATERIAL_RETRUDE_MATERIAL retract is E$2 in gcode_macro.cfg"
        else
            log_warn "Retract line not found in QUIT_MATERIAL_RETRUDE_MATERIAL (gcode_macro.cfg)"
        fi
    fi
    if [ -f "$BOX_CFG" ]; then
        # POSIX BRE only (busybox/musl): the value must not continue as another digit
        sed -i "s/^Tn_retrude:[[:space:]]*$3\([^0-9].*\)\{0,1\}$/Tn_retrude: $4\1/" "$BOX_CFG"
        if grep -q "^Tn_retrude:[[:space:]]*$4\([^0-9].*\)\{0,1\}$" "$BOX_CFG"; then
            log_success "Tn_retrude is $4 in box.cfg"
        else
            log_warn "Tn_retrude not found in box.cfg"
        fi
    fi
}

patch_dxc_configs() {
    log_info "Applying DXC-2 patches..."
    set_dxc_values -10 -40 -10 -20
    mark_installed "dxc_patch"
}

restore_dxc_configs() {
    log_info "Reverting DXC-2 patches to stock values..."
    # Reverse the edit instead of copying a backup: after a Creality update an
    # old backup would put back the previous firmware's config.
    set_dxc_values -40 -10 -20 -10
    mark_removed "dxc_patch"
}

case "$1" in
    patch)   patch_dxc_configs ;;
    restore) restore_dxc_configs ;;
    # rc.local: reapply after a Creality update replaced the configs
    boot)    is_installed "dxc_patch" && set_dxc_values -10 -40 -10 -20 ;;
    *)       echo "Usage: $0 [patch|restore|boot]" ;;
esac
