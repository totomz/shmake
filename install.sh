#!/usr/bin/env sh
set -e

REPO="https://raw.githubusercontent.com/totomz/shmake/refs/heads/main"

_download() {
  url=$1
  dest=$2
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$dest"
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$url" -O "$dest"
  else
    echo "error: one of curl or wget is required" >&2
    exit 1
  fi
}

_download "${REPO}/shMakefile" ./shMakefile
_download "${REPO}/functions.sh" ./functions.sh
chmod +x ./shMakefile

echo "shmake installed. Run ./shMakefile --help to get started."
