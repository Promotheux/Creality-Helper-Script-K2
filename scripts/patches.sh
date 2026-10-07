#!/bin/sh
# patch_dxc.sh - Patch configurations for DXC K2 Series with backup/restore support
SCRIPT_DIR=/mnt/UDISK/helper-script
. "$SCRIPT_DIR/scripts/system.sh"

patch_dxc_configs() {
    local macro_cfg="$CONFIG_DIR/gcode_macro.cfg"
    local box_cfg="$CONFIG_DIR/box.cfg"

    log_info "Applying DXC K2 Series patches..."

    # 1. Backup maken voordat we iets aanpassen (als de backup nog niet bestaat)
    if [ -f "$macro_cfg" ] && [ ! -f "${macro_cfg}.dxc_bak" ]; then
        cp "$macro_cfg" "${macro_cfg}.dxc_bak"
        log_success "Backup gemaakt van gcode_macro.cfg"
    fi

    if [ -f "$box_cfg" ] && [ ! -f "${box_cfg}.dxc_bak" ]; then
        cp "$box_cfg" "${box_cfg}.dxc_bak"
        log_success "Backup gemaakt van box.cfg"
    fi

    # 2. Gcode_macro.cfg patchen: G0 E-10 F360 -> G0 E-40 F360
    if [ -f "$macro_cfg" ]; then
        if grep -q "G0 E-10 F360" "$macro_cfg"; then
            sed -i 's/G0 E-10 F360/G0 E-40 F360/g' "$macro_cfg"
            log_success "Patched QUIT_MATERIAL_RETRUDE_MATERIAL in gcode_macro.cfg (-10 -> -40)"
        else
            log_info "gcode_macro.cfg al gepatcht of doelregel niet gevonden."
        fi
    fi

    # 3. Box.cfg patchen: Tn_retrude -10 -> -20
    if [ -f "$box_cfg" ]; then
        if grep -q "Tn_retrude" "$box_cfg"; then
            sed -i 's/Tn_retrude:[[:space:]]*-10/Tn_retrude: -20/g' "$box_cfg"
            log_success "Patched Tn_retrude in box.cfg (-10 -> -20)"
        else
            log_info "box.cfg al gepatcht of Tn_retrude niet gevonden."
        fi
    fi
}

restore_dxc_configs() {
    local macro_cfg="$CONFIG_DIR/gcode_macro.cfg"
    local box_cfg="$CONFIG_DIR/box.cfg"

    log_info "Terugdraaien van DXC K2 Series patches..."

    if [ -f "${macro_cfg}.dxc_bak" ]; then
        cp "${macro_cfg}.dxc_bak" "$macro_cfg"
        log_success "Originele gcode_macro.cfg hersteld vanuit backup."
    else
        log_warn "Geen backup gevonden voor gcode_macro.cfg"
    fi

    if [ -f "${box_cfg}.dxc_bak" ]; then
        cp "${box_cfg}.dxc_bak" "$box_cfg"
        log_success "Originele box.cfg hersteld vanuit backup."
    else
        log_warn "Geen backup gevonden voor box.cfg"
    fi
}

case "$1" in
    patch)   patch_dxc_configs ;;
    restore) restore_dxc_configs ;;
    *)       echo "Usage: $0 [patch|restore]" ;;
esac