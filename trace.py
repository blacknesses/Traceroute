#!/usr/bin/env python3

import subprocess
import re
import os
import sys
from colorama import init, Fore
from concurrent.futures import ThreadPoolExecutor, as_completed

# Inicializa o Colorama para cores no terminal
init(autoreset=True)

# Define a versão do script
VERSION = "1.0.0"

# Cache para armazenar resultados do whois e evitar reconsultas desnecessárias
whois_cache = {}

# Função para realizar uma consulta whois e retornar o proprietário do IP
def get_whois_owner(ip_address):
    # Verifica se o resultado do whois já está em cache
    if ip_address in whois_cache:
        return whois_cache[ip_address]

    try:
        # Executa o comando whois e captura a saída
        whois_cmd = ["whois", ip_address]
        result = subprocess.run(whois_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        whois_output = result.stdout.decode()

        # Procura pela linha que contém o proprietário do IP (OrgName ou owner)
        owner_regexes = [
            re.compile(r'OrgName:\s*(.*)'),  # Verifica o campo OrgName
            re.compile(r'owner:\s*(.*)', re.IGNORECASE)  # Verifica o campo owner
        ]

        # Tenta encontrar o primeiro campo disponível
        for regex in owner_regexes:
            match = regex.search(whois_output)
            if match:
                whois_cache[ip_address] = match.group(1).strip()  # Armazena no cache
                return whois_cache[ip_address]

        # Se não encontrar nenhum dos campos, armazenar como "Unknown"
        whois_cache[ip_address] = "Unknown"
        return "Unknown"
    except Exception:
        whois_cache[ip_address] = "Whois error"
        return "Whois error"

# Função para verificar se um IP é privado (RFC 1918)
def is_private_ip(ip_address):
    private_ranges = [
        re.compile(r"^10\."),              # 10.0.0.0 - 10.255.255.255
        re.compile(r"^172\.(1[6-9]|2[0-9]|3[01])\."),  # 172.16.0.0 - 172.31.255.255
        re.compile(r"^192\.168\.")         # 192.168.0.0 - 192.168.255.255
    ]
    return any(regex.match(ip_address) for regex in private_ranges)

# Função principal do traceroute
def traceroute(host):
    # Identifica o comando apropriado para traceroute com base no sistema operacional
    traceroute_cmd = ["tracert", host] if os.name == 'nt' else ["traceroute", "-n", host]

    # Executa o comando traceroute e captura a saída
    result = subprocess.run(traceroute_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    traceroute_output = result.stdout.decode()

    # Divide a saída do traceroute em linhas
    lines = traceroute_output.splitlines()

    # Expressão regular para capturar hop, IP e ms (adicionando casos onde não há IP)
    hop_regex = re.compile(r'^\s*(\d+)\s+([\d\.*]+)\s+(\d+\.?\d*)\s+ms|^\s*(\d+)\s+\*\s+\*\s+\*\s+')

    hop_count = 0
    valid_hop_count = 0  # Contador para hops válidos exibidos
    ms_times = []
    whois_futures = []

    # Utilizando ThreadPoolExecutor para paralelizar whois
    with ThreadPoolExecutor() as executor:
        for line in lines:
            hop_match = hop_regex.search(line)
            if hop_match:
                if hop_match.group(2):  # Caso onde temos um IP e tempo de resposta
                    hop_number = hop_match.group(1)
                    ip_address = hop_match.group(2)
                    ms_time = float(hop_match.group(3))  # Convertendo o tempo para float

                    # Incrementa a contagem de hops
                    hop_count += 1
                    ms_times.append(ms_time)

                    # Verifica se o IP é privado e exibe a respectiva RFC, ou realiza whois
                    if is_private_ip(ip_address):
                        provider_name = "RFC 1918 (Private IP)"
                    else:
                        # Agendar a execução do whois de forma paralela
                        whois_futures.append(
                            (hop_number, ip_address, ms_time, executor.submit(get_whois_owner, ip_address))
                        )
                    # Saída imediata de hops com IP
                    print(f"Hop {Fore.GREEN}{hop_number}{Fore.RESET}: IP {Fore.GREEN}{ip_address}{Fore.RESET}, Time: {Fore.GREEN}{ms_time}{Fore.RESET} ms")

                elif hop_match.group(4):  # Caso onde temos saltos sem retorno (* * *)
                    hop_number = hop_match.group(4)
                    hop_count += 1
                    # Exibe um hop com * * * (sem resposta de IP)
                    print(f"Hop {Fore.RED}{hop_number}{Fore.RESET}: Sem resposta (* * *)")

        # Processa os resultados do whois à medida que as threads são concluídas
        for hop_number, ip_address, ms_time, future in whois_futures:
            provider_name = future.result()  # Recupera o resultado do whois
            # Exibe a informação do provider apenas para os hops válidos
            if provider_name != "Unknown" and provider_name != "Whois error":
                print(f"{Fore.YELLOW}[Whois]{Fore.RESET} Hop {Fore.GREEN}{hop_number}{Fore.RESET}: IP {Fore.GREEN}{ip_address}{Fore.RESET}, Provider: {Fore.GREEN}{provider_name}{Fore.RESET}")

    # Calcula os valores mínimo, médio e máximo dos tempos em ms
    if ms_times:
        min_ms = min(ms_times)
        max_ms = max(ms_times)
        avg_ms = sum(ms_times) / len(ms_times)

        # Exibe os resultados ao final do traceroute
        print(f"\nTraceroute concluído com {Fore.GREEN}{hop_count}{Fore.RESET} saltos.")
        print(f"Min: {Fore.GREEN}{min_ms:.2f}{Fore.RESET} ms")
        print(f"Avg: {Fore.GREEN}{avg_ms:.2f}{Fore.RESET} ms")
        print(f"Max: {Fore.GREEN}{max_ms:.2f}{Fore.RESET} ms")
        print(f"Destino: {host}")
    else:
        print("Rotas não encontradas!")

if __name__ == "__main__":
    if len(sys.argv) == 2 and sys.argv[1] in ("--version", "-v"):
        print(f"Versão do script: {VERSION}")
        sys.exit(0)

    if len(sys.argv) != 2:
        print(f"Uso: {sys.argv[0]} <host> ou {sys.argv[0]} --version")
        sys.exit(1)
    
    host = sys.argv[1]
    traceroute(host)
