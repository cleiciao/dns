#!/bin/bash

# URL do script Python hospedado
SCRIPT_URL="https://raw.githubusercontent.com/cleiciao/dns/main/block.py"

# Caminho para salvar o script baixado
SCRIPT_PATH="/etc/unbound/block.py"

# Baixar o script usando curl
echo "Baixando o script de RPZ..."
curl -o $SCRIPT_PATH $SCRIPT_URL

# Verificar se o download foi bem-sucedido
if [ $? -ne 0 ]; then
  echo "Falha ao baixar o script. Verifique a URL e a conexão de rede."
  exit 1
fi

# Adicionar permissão de execução ao script
echo "Adicionando permissão de execução ao script..."
chmod +x $SCRIPT_PATH

# Executar o script Python
echo "Executando o script..."
python3 $SCRIPT_PATH

# Verificar se a execução foi bem-sucedida
if [ $? -ne 0 ]; then
  echo "Falha ao executar o script. Verifique o script Python para erros."
  exit 1
fi

# Adicionar agendamento ao crontab
echo "Agendando a execução diária do script no crontab..."
(crontab -l ; echo "0 3 * * * python3 $SCRIPT_PATH") | crontab -

if [ $? -eq 0 ]; then
  echo "Script agendado com sucesso para ser executado diariamente às 3:00 AM."
else
  echo "Falha ao agendar o script. Verifique as permissões do crontab."
  exit 1
fi


echo "Script executado com sucesso."
