#!/bin/bash

REPO_URL="https://github.com/blacknesses/Traceroute"
TEMP_DIR=$(mktemp -d)  # Cria uma pasta temporária
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="trace.py"
SCRIPT_PATH="$INSTALL_DIR/trace"

# Função para barra de progresso
progress_bar() {
    local duration=$1
    local already_done=0
    local pending=$(($duration))
    local bar=""

    while [ $already_done -lt $duration ]; do
        already_done=$((already_done + 1))
        pending=$((pending - 1))
        bar=$(printf "%-${already_done}s" "=")
        printf "\r[%s>%*s] %d%%" "$bar" $pending "" $((already_done * 100 / duration))
        sleep 0.1
    done
    printf "\n"
}

# Iniciar o processo de instalação
echo "Status: iniciando a instalação...          ✓ [OK]"

# Baixar o repositório na pasta temporária
echo "Status: baixando arquivos...               ✓ [OK]"
git clone $REPO_URL $TEMP_DIR >/dev/null 2>&1  # Removi a execução em background
progress_bar 20  # Simula a barra de progresso (20 iterações)
if [ $? -eq 0 ]; then
    echo "Status: repositório clonado com sucesso!   ✓ [OK]"
else
    echo "Status: falha ao clonar o repositório! ✗ [FALHA]" >&2
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Definir permissões e mover o script para o diretório de instalação
echo "Status: configurando permissões...         ✓ [OK]"
sudo chmod +x "$TEMP_DIR/$SCRIPT_NAME" >/dev/null 2>&1  # Corrigi a variável do script
sudo mv "$TEMP_DIR/$SCRIPT_NAME" "$SCRIPT_PATH" >/dev/null 2>&1
progress_bar 10  # Simula a barra de progresso (10 iterações)
if [ $? -eq 0 ]; then
    echo "Status: permissões configuradas!            ✓ [OK]"
else
    echo "Status: falha ao configurar permissões! ✗ [FALHA]" >&2
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Remover a pasta temporária após a instalação
rm -rf "$TEMP_DIR"

# Finalizar a instalação
echo "Status: instalação finalizada com sucesso! ✓ [OK]"
echo ""
echo "-------------------------"
echo "Sintaxe: trace IP/Domain"
echo "-------------------------"
