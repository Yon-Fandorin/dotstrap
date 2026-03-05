#!/usr/bin/env bash
# install.sh — Remote installer for dotstrap
# Usage: curl -fsSL https://raw.githubusercontent.com/Yon-Fandorin/dotstrap/main/install.sh | bash

set -euo pipefail

REPO="https://github.com/Yon-Fandorin/dotstrap.git"
INSTALL_DIR="${HOME}/.dotstrap"

if [[ -d "$INSTALL_DIR/.git" ]]; then
    echo "Updating existing dotstrap..."
    git -C "$INSTALL_DIR" pull
else
    echo "Cloning dotstrap..."
    git clone "$REPO" "$INSTALL_DIR"
fi

bash "${INSTALL_DIR}/bootstrap.sh" "$@"
