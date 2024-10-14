#!/bin/bash

# Nome do repositório GitHub
REPO_URL="https://github.com/blacknesses/Traceroute"

# Diretório temporário para clonar o repositório
TEMP_DIR=$(mktemp -d)

# Clonar o repositório
echo "Status: clonando o repositório... [OK]"
git clone $REPO_URL $TEMP_DIR > dev/null

# Mover o script ou programa para /usr/local/bin
echo "Status: instalando o programa... [OK]"
sudo mv $TEMP_DIR/trace.py /usr/local/bin/trace

# Tornar o script executável
sudo chmod +x /usr/local/bin/trace

# Limpar o diretório temporário
rm -rf $TEMP_DIR

echo "Status: instalação concluída! Agora você pode usar 'trace' no terminal."
echo "Sintaxe: trace IP/Doamain"
