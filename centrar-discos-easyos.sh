#!/bin/sh
# Centrar la fila de discos de EasyOS y elevarla sobre el dock.
set -eu
aviso() {
    printf '%s\n' "$1"
    if command -v xmessage >/dev/null 2>&1; then
        xmessage -center "$1" || true
    fi
}
CONFIG=/etc/eventmanager
PIN=/root/Choices/ROX-Filer/PuppyPin
[ "$(id -u)" = 0 ] || { aviso 'Ejecuta este script como root en EasyOS.'; exit 1; }
[ -f "$CONFIG" ] && [ -f "$PIN" ] || {
    aviso 'No encuentro la configuracion de EasyOS o PuppyPin. No se ha cambiado nada.'
    exit 1
}
command -v xwininfo >/dev/null 2>&1 || { aviso 'Falta xwininfo. No se ha cambiado nada.'; exit 1; }
ANCHO=$(xwininfo -root | awk '/Width:/ {print $2; exit}')
NUM=$(grep -c '/root/.pup_event/drive_' "$PIN" || true)
case "$ANCHO:$NUM" in *[!0-9:]*|:*) aviso 'No puedo detectar la pantalla o los discos.'; exit 1;; esac
[ "${ANCHO:-0}" -gt 0 ] && [ "$NUM" -gt 0 ] || { aviso 'No se detectaron iconos de discos.'; exit 1; }
for VARIABLE in ICON_PLACE_EDGE_GAP ICON_PLACE_START_GAP ICON_PLACE_SPACING ICON_PLACE_ORIENTATION; do
    grep -q "^${VARIABLE}=" "$CONFIG" || { aviso "Falta $VARIABLE. No se ha cambiado nada."; exit 1; }
done
ESPACIO=68
INICIO=$(( (ANCHO - (NUM - 1) * ESPACIO) / 2 ))
[ "$INICIO" -ge 32 ] || INICIO=32
FECHA=$(date +%Y%m%d-%H%M%S)
cp -a "$CONFIG" "$CONFIG.bak-$FECHA"
sed -i \
    -e 's/^ICON_PLACE_EDGE_GAP=.*/ICON_PLACE_EDGE_GAP=150/' \
    -e "s/^ICON_PLACE_START_GAP=.*/ICON_PLACE_START_GAP=$INICIO/" \
    -e "s/^ICON_PLACE_SPACING=.*/ICON_PLACE_SPACING=$ESPACIO/" \
    -e "s/^ICON_PLACE_ORIENTATION=.*/ICON_PLACE_ORIENTATION='bottom'/" \
    "$CONFIG"
aviso "ENGLISH
Settings saved for $NUM icons, raised above the dock.

1. Menu > Desktop > Desktop drive icon manager.
2. Tick the box: Erase then redraw and realign existing icons.
3. Click OK.
4. Restart X.

ESPAÑOL
Configuración guardada para $NUM iconos, elevados sobre el dock.

1. Menu > Desktop > Desktop drive icon manager.
2. Marca la casilla: Erase then redraw and realign existing icons.
3. Pulsa OK.
4. Reinicia X (Restart X).

Backup / Copia de seguridad: $CONFIG.bak-$FECHA

...by pp4mnk"
