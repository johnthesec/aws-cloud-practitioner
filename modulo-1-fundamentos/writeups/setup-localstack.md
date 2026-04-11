# Setup do ambiente AWS com LocalStack

> **Módulo:** Módulo 1 — Fundamentos & Setup do ambiente
> **Tipo:** `writeup`
> **Dificuldade:** Iniciante
> **Data:** 2026-04-11

---

## 🎯 Objetivo

Configurar um ambiente local para estudar e praticar os serviços da AWS sem custo — usando LocalStack, AWS CLI e awslocal — e executar o primeiro comando real contra um serviço simulado.

---

## 🧠 Contexto

Criar uma conta AWS e usar os serviços reais tem um risco: qualquer recurso esquecido ligado pode gerar cobrança. Para quem está aprendendo, o LocalStack resolve esse problema — ele simula os serviços da AWS localmente, dentro de um container Docker. A AWS CLI se comporta exatamente igual, só que aponta para `localhost:4566` em vez dos servidores da Amazon.

Isso permite errar sem consequência financeira, aprender a CLI com calma e depois migrar para a conta AWS real já sabendo o que está fazendo.

---

## ⚙️ Ambiente

| Item | Valor |
|---|---|
| Sistema operacional | Ubuntu 24.04 LTS (WSL) |
| Usuário utilizado | `john` |
| Docker | 28.2.2 |
| AWS CLI | 2.34.29 |
| LocalStack | 2026.3.0 |
| Conta LocalStack | Gratuita (trial 45 dias) |

---

## 📋 Passo a passo

### Passo 1 — Verificando pré-requisitos

```bash
docker --version
python3 --version
pip3 --version
```

O Docker já estava instalado. O pip3 não estava presente — instalamos antes de continuar:

```bash
sudo apt install python3-pip -y
```

---

### Passo 2 — Instalando awslocal e localstack CLI

```bash
pip3 install awscli-local localstack --break-system-packages
```

**O que cada ferramenta faz:**
- `localstack` — CLI para gerenciar o container LocalStack (start, stop, status)
- `awscli-local` — wrapper da AWS CLI que redireciona todos os comandos para `localhost:4566` em vez da AWS real. O comando vira `awslocal` em vez de `aws`

O pip instalou os binários em `/home/john/.local/bin` — mas esse caminho não estava no PATH:

```
WARNING: The script localstack is installed in '/home/john/.local/bin' which is not on PATH.
```

**Solução:**

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

O `>>` adiciona ao final do arquivo sem sobrescrever. O `source` aplica as mudanças na sessão atual sem precisar fechar o terminal.

---

### Passo 3 — Instalando a AWS CLI oficial

O `awslocal` depende da AWS CLI oficial para funcionar. O apt não tinha o pacote disponível no Ubuntu 24.04, então instalamos direto do site da Amazon:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**O que cada parte faz:**
- `curl ... -o "awscliv2.zip"` — baixa o instalador e salva com o nome especificado
- `unzip` — descompacta o arquivo
- `sudo ./aws/install` — roda o instalador oficial (precisa de root para escrever em `/usr/local/bin`)

**Verificação:**

```bash
aws --version
# aws-cli/2.34.29 Python/3.14.3 Linux/6.6.87.2-microsoft-standard-WSL2
awslocal --version
# aws-cli/2.34.29 Python/3.14.3 Linux/6.6.87.2-microsoft-standard-WSL2
```

---

### Passo 4 — Criando conta no LocalStack e obtendo o token

Acesso em [app.localstack.cloud](https://app.localstack.cloud) → criar conta gratuita → **Settings → Auth Tokens → Personal Auth Token**.

O token tem o formato `ls-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`.

Configurando na sessão atual e salvando permanentemente:

```bash
export LOCALSTACK_AUTH_TOKEN=ls-seu-token-aqui
echo "export LOCALSTACK_AUTH_TOKEN=ls-seu-token-aqui" >> ~/.bashrc
```

> **Atenção:** nunca commite o token no repositório. Se usar `.env`, adicione ao `.gitignore`.

---

### Passo 5 — Subindo o LocalStack via Docker

```bash
docker run -d \
  --name localstack \
  -p 4566:4566 \
  -e LOCALSTACK_AUTH_TOKEN=$LOCALSTACK_AUTH_TOKEN \
  localstack/localstack
```

**O que cada flag faz:**
- `-d` — detached: roda em background, igual ao `systemctl start` do Linux
- `--name localstack` — nomeia o container para referenciá-lo depois
- `-p 4566:4566` — mapeia a porta do container para a máquina local (`host:container`)
- `-e` — passa variável de ambiente para dentro do container
- `localstack/localstack` — imagem oficial do LocalStack no Docker Hub

Na primeira execução baixou a imagem (~500MB). Nas próximas, sobe em segundos.

---

### Passo 6 — Diagnosticando e corrigindo problemas

Três problemas apareceram durante o setup — todos resolvidos:

**Problema 1 — Docker sem internet (DNS):**

O container não conseguia acessar a internet para validar a licença:

```
Reason: Could not reach the LocalStack licensing server at https://api.localstack.cloud/v1
```

Diagnóstico:
```bash
docker run --rm alpine ping -c 2 google.com
# ping: bad address 'google.com'
```

Solução — configurar DNS no Docker:

```bash
sudo nano /etc/docker/daemon.json
```

```json
{
  "dns": ["8.8.8.8", "8.8.4.4"]
}
```

```bash
sudo service docker restart
```

**Problema 2 — Permissão no socket do Docker:**

```
permission denied while trying to connect to the Docker daemon socket
```

Solução:
```bash
sudo usermod -aG docker john
newgrp docker
```

O `usermod -aG` adiciona o usuário ao grupo `docker` sem remover dos outros grupos. O `newgrp` aplica o novo grupo na sessão atual sem precisar fazer logout.

---

### Passo 7 — Verificando o ambiente e primeiro comando

```bash
curl http://localhost:4566/_localstack/health
```

Retornou todos os serviços com status `available` — S3, IAM, EC2, VPC e mais de 100 outros.

**Primeiro comando real — criando um bucket S3:**

```bash
awslocal s3 mb s3://meu-primeiro-bucket
# make_bucket: meu-primeiro-bucket

awslocal s3 ls
# 2026-04-11 13:33:07 meu-primeiro-bucket
```

`mb` = make bucket. O mesmo comando funciona na AWS real — só substituindo `awslocal` por `aws`.

---

## 💡 Conceitos aprendidos

- **LocalStack** — simulador de serviços AWS que roda localmente via Docker
- **awslocal** — wrapper da AWS CLI que aponta para `localhost:4566`
- **`-p host:container`** — mapeamento de porta no Docker
- **`-e`** — variável de ambiente passada para o container
- **`export`** — torna uma variável disponível para processos filhos (como o Docker)
- **DNS no Docker** — containers usam DNS próprio, configurável em `daemon.json`
- **`usermod -aG`** — adiciona usuário a grupo sem remover dos outros
- **`awslocal s3 mb`** — cria um bucket S3 via CLI

---

## ⚠️ Erros que cometi (e como resolvi)

**Erro 1 — Pacote errado no apt:**
```
sudo apt install python-pip   # errado
sudo apt install python3-pip  # correto
```
Causa: digitei `python-pip` em vez de `python3-pip`. No Ubuntu 24.04 só existe a versão 3.

**Erro 2 — Hífens em vez de underscores na variável:**
```
-e LOCALSTACK-AUTH-TOKEN   # errado — o container não recebeu o token
-e LOCALSTACK_AUTH_TOKEN   # correto
```
Causa: copiei o nome da variável com hífens. Variáveis de ambiente usam underscore.

**Erro 3 — Flag `-p` sem o hífen:**
```
docker run -d --name localstack p 4566:4566 ...
# Error: unable to find image 'p:latest'
```
Causa: o Docker interpretou `p` como nome de imagem. A flag correta é `-p`.

**Erro 4 — Container sem acesso à internet:**
O LocalStack não conseguia validar a licença porque o Docker no WSL não resolvia DNS.
Causa: configuração padrão do Docker não inclui servidores DNS externos.
Solução: adicionei `8.8.8.8` e `8.8.4.4` no `/etc/docker/daemon.json`.

---

## ✅ Resultado final

Ambiente completo de estudo AWS configurado e funcionando:

```
Docker 28.2.2       ✅
AWS CLI 2.34.29     ✅
LocalStack 2026.3.0 ✅ (licença ativada)
awslocal            ✅ (apontando para localhost:4566)
Primeiro bucket S3  ✅ (meu-primeiro-bucket)
```

Próximo passo: Módulo 2 — IAM.

---

## 📎 Arquivos relacionados

| Arquivo | Descrição |
|---|---|
| `README.md` | visão geral do repositório e como reproduzir o ambiente |

---

## 🔗 Referências

- [Documentação oficial do LocalStack](https://docs.localstack.cloud)
- [AWS CLI — instalação no Linux](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [awscli-local no PyPI](https://pypi.org/project/awscli-local/)
- `aws s3 help` — manual dos comandos S3 via CLI
