REPO_URL="https://github.com/blacknesses/Traceroute"
TEMP_DIR=$(mktemp -d)  # Cria uma pasta temporária
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="trace.py"
SCRIPT_PATH="$INSTALL_DIR/$SCRIPT_NAME"  # Movendo como trace.py

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

# Função de desinstalação
uninstall_trace() {
    echo "Status: iniciando a desinstalação...       ✓ [OK]"
    
    # Verifica se o arquivo existe
    if [ -f "$SCRIPT_PATH" ]; then
        sudo rm "$SCRIPT_PATH" >/dev/null 2>&1
        progress_bar 10
        if [ $? -eq 0 ]; then
            echo "Status: desinstalação concluída com sucesso! ✓ [OK]"
        else
            echo "Status: falha ao remover o script!         ✗ [FALHA]" >&2
            exit 1
        fi
    else
        echo "Status: script não encontrado!             ✗ [FALHA]" >&2
        exit 1
    fi
}

# Função de instalação
install_trace() {
    echo "Status: iniciando a instalação...          ✓ [OK]"

    # Baixar o repositório na pasta temporária
    echo "Status: baixando arquivos...               ✓ [OK]"
    git clone $REPO_URL $TEMP_DIR >/dev/null 2>&1  # Removi a execução em background
    progress_bar 20  # Simula a barra de progresso (20 iterações)
    if [ $? -eq 0 ]; then
        echo "Status: repositório clonado com sucesso!   ✓ [OK]"
    else
        echo "Status: falha ao clonar o repositório!     ✗ [FALHA]" >&2
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    # Definir permissões e mover o script para o diretório de instalação
    echo "Status: configurando permissões...         ✓ [OK]"
    sudo chmod +x "$TEMP_DIR/$SCRIPT_NAME" >/dev/null 2>&1
    sudo mv "$TEMP_DIR/$SCRIPT_NAME" "$SCRIPT_PATH" >/dev/null 2>&1  # Mudança aqui
    progress_bar 10  # Simula a barra de progresso (10 iterações)
    if [ $? -eq 0 ]; then
        echo "Status: permissões configuradas!           ✓ [OK]"
    else
        echo "Status: falha ao configurar permissões!    ✗ [FALHA]" >&2
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    # Remover a pasta temporária após a instalação
    rm -rf "$TEMP_DIR"

    # Finalizar a instalação
    echo "Status: instalação finalizada com sucesso! ✓ [OK]"
    echo ""
    echo "-------------------------"
    echo "Sintaxe: trace.py IP/Domain"
    echo "-------------------------"
}

menu() {
# Menu de opções: instalação ou desinstalação
echo "Escolha uma opção:"
echo "1) Instalar"
echo "2) Desinstalar"
read -p "Digite o número da opção: " option
while true; do
    if [ "$option" == "1" ]; then
        install_trace
    elif [ "$option" == "2" ]; then
        uninstall_trace
    else
        echo "Opção inválida..."
        menu
    fi
done
}
