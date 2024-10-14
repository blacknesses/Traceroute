#!/bin/bash

INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="trace"

# Verificar se o script está instalado
if [ -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
    echo "Removendo o script $SCRIPT_NAME..."
    sudo rm "$INSTALL_DIR/$SCRIPT_NAME"
    if [ $? -eq 0 ]; then
        echo "Desinstalação concluída com sucesso! ✓ [OK]"
    else
        echo "Falha ao desinstalar o script! ✗ [FALHA]" >&2
        exit 1
    fi
else
    echo "O script $SCRIPT_NAME não está instalado." >&2
    exit 1
fi
