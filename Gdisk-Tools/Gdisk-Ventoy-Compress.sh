#!/bin/bash
# Gdisk-Ventoy-Compress.sh - Launcher for the compressor toolset
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZIP_PATH="$SCRIPT_DIR/Gdisk-Ventoy-Compress.zip"
cat << 'BANNER'

+------------------------------------------------------------+
|         Gdisk Ventoy Compressor (TianoCompress)            |
|   wraps any Ventoy .img into a grub-bootable .vtoy file    |
+------------------------------------------------------------+

BANNER
if [ ! -f "$ZIP_PATH" ]; then
    echo "[!!] Bundle not found: $ZIP_PATH"
    echo "     Place Gdisk-Ventoy-Compress.zip alongside this script."
    exit 1
fi
missing=()
for cmd in python3 unzip; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done
if [ ${#missing[@]} -gt 0 ]; then
    echo "[!!] Required tools missing: ${missing[*]}"
    echo "     Install with: sudo apt install ${missing[*]}"
    exit 1
fi
WORK_DIR=$(mktemp -d -t gdisk-ventoy-compress.XXXXXX)
trap "rm -rf '$WORK_DIR'" EXIT INT TERM
echo "[..] Extracting toolset to $WORK_DIR"
unzip -q -o "$ZIP_PATH" -d "$WORK_DIR"
required=(gdiskchain_build.py vdiskchain.efi ipxe.krn TianoCompress magic.bin)
for f in "${required[@]}"; do
    if [ ! -f "$WORK_DIR/$f" ]; then
        echo "[!!] Bundle is missing: $f"
        exit 1
    fi
done
chmod +x "$WORK_DIR/TianoCompress"
echo "[OK] Bundle ready ($(ls -1 "$WORK_DIR" | wc -l) files)"
exec python3 "$WORK_DIR/gdiskchain_build.py" "$WORK_DIR"
