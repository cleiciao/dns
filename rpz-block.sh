#!/bin/bash

# URL do script Python hospedado com o token de segurança
SCRIPT_URL="https://r3o0.mi.idrivee2-30.com/bloqueio.py?token=4IFw6mP7DopyYMb4HQ8pModJfb3eWyn9gMZnssMn"

# Caminho para salvar o script baixado
SCRIPT_PATH="/etc/unbound/bloqueio.py"

# Baixar o script Python usando curl com o token de segurança
echo "Baixando o script Python..."
curl -o $SCRIPT_PATH "$SCRIPT_URL"

# Verificar se o download foi bem-sucedido
if [ $? -ne 0 ]; then
  echo "Falha ao baixar o script. Verifique a URL e o token de segurança."
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
  echo "Falha ao executar o script Python. Verifique o script para erros."
  exit 1
fi

echo "Script Python executado com sucesso."

# Adicionar agendamento ao crontab
echo "Agendando a execução diária do script no crontab..."
CRON_JOB="0 3 * * * python3 $SCRIPT_PATH"
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

if [ $? -eq 0 ]; then
  echo "Script agendado com sucesso para ser executado diariamente às 3:00 AM."
else
  echo "Falha ao agendar o script. Verifique as permissões do crontab."
  exit 1
fi
