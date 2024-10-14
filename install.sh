#!/bin/bash

REPO_URL="https://github.com/blacknesses/Traceroute"
TEMP_DIR=$(mktemp -d)  # Cria uma pasta temporária
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="trace.py"  # Certifique-se de que este seja o nome correto do arquivo
SCRIPT_PATH="$INSTALL_DIR/trace"  # O nome final será "trace"
UNINSTALLER_PATH="/usr/local/bin/uninstall_trace.sh"

# Função para barra de progresso
progress_bar() {
    local duration=$1
    local bar=""
    local percentage=0

    for ((i=1; i<=duration; i++)); do
        bar="${bar}="
        percentage=$((i * 100 / duration))
        printf "\r[%s] %d%%" "$bar" "$percentage"
        sleep 0.1
    done
    printf "\n"
}

# Função de instalação
install_trace() {
    echo "Status: iniciando a instalação...          ✓ [OK]"

    # Baixar o repositório na pasta temporária
    echo "Status: baixando arquivos...               ✓ [OK]"
    git clone $REPO_URL $TEMP_DIR >/dev/null 2>&1
    progress_bar 20  # Simula a barra de progresso (20 iterações)
    if [ $? -eq 0 ]; then
        echo "Status: repositório clonado com sucesso!   ✓ [OK]"
    else
        echo "Status: falha ao clonar o repositório!     ✗ [FALHA]" >&2
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    # Verificar se o script existe
    if [ -f "$TEMP_DIR/$SCRIPT_NAME" ]; then
        echo "Status: configurando permissões...         ✓ [OK]"
        sudo chmod +x "$TEMP_DIR/$SCRIPT_NAME" >/dev/null 2>&1
        sudo mv "$TEMP_DIR/$SCRIPT_NAME" "$SCRIPT_PATH" >/dev/null 2>&1
        progress_bar 10  # Simula a barra de progresso (10 iterações)
        if [ $? -eq 0 ]; then
            echo "Status: permissões configuradas!           ✓ [OK]"
        else
            echo "Status: falha ao configurar permissões!    ✗ [FALHA]" >&2
            rm -rf "$TEMP_DIR"
            exit 1
        fi
    else
        echo "Erro: arquivo $SCRIPT_NAME não encontrado no repositório!" >&2
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    # Criar script de desinstalação
    echo "Status: criando script de desinstalação...  ✓ [OK]"
    cat <<EOF | sudo tee $UNINSTALLER_PATH >/dev/null
#!/bin/bash
echo "Status: desinstalando trace... ✓ [OK]"
if [ -f "$SCRIPT_PATH" ]; then
    sudo rm "$SCRIPT_PATH"
    echo "Status: trace removido com sucesso! ✓ [OK]"
else
    echo "trace não encontrado!"
fi
rm -- "\$0"  # Remove este script após a execução
EOF
    sudo chmod +x $UNINSTALLER_PATH

    # Remover a pasta temporária
    rm -rf "$TEMP_DIR"

    # Finalizar instalação
    echo "Status: instalação finalizada com sucesso! ✓ [OK]"
    echo ""
    echo "-------------------------"
    echo "Sintaxe: trace IP/Domain"
    echo "-------------------------"
    echo "OBS: Para desinstalar o programa, execute: sudo /usr/local/bin/uninstall_trace.sh"
    echo ""
}

# Inicia a instalação automaticamente
install_trace
