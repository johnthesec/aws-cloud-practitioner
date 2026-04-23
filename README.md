# ☁️ AWS Cloud Practitioner Portfolio

> Repositório de aprendizado prático em computação em nuvem com AWS.  
> Cada módulo contém writeups explicativos, comandos reais e desafios resolvidos.

---

## 👤 Sobre este repositório

Continuação do [Linux SysAdmin Portfolio](https://github.com/johnthesec/linux-sysadmin-portfolio) — agora aplicando os mesmos conceitos de servidores, redes e segurança no ambiente de nuvem da AWS.

Todo o aprendizado prático é feito com **LocalStack** (ambiente AWS local e gratuito) antes de migrar para a conta AWS Free Tier.

**Objetivo final:** dominar os serviços fundamentais da AWS usados no dia a dia de sysadmins e engenheiros de infraestrutura, com evidências concretas de cada etapa.

---

## 🗺️ Roadmap de aprendizado

```
Módulo 1 → Fundamentos e setup do ambiente    ✅ Concluído
Módulo 2 → IAM — controle de acesso           ✅ Concluído
Módulo 3 → VPC — rede na nuvem               🔄 Em andamento
Módulo 4 → EC2 — servidores virtuais
Módulo 5 → S3 — armazenamento de objetos
Módulo 6 → Segurança — Security Groups, CloudTrail
```

---

## 📁 Estrutura do repositório

```
aws-cloud-practitioner/
│
├── README.md                                    ← você está aqui
│
├── modulo-1-fundamentos/
│   └── writeups/
│       └── setup-localstack.md                  ← instalação e configuração do ambiente
│
├── modulo-2-iam/
│   ├── scripts/
│   │   └── criar-politica.sh                    ← criando usuário e política via CLI
│   ├── writeups/
│   │   └── iam-guide.md                         ← users, groups, roles, policies
│   └── desafios/
│       └── least-privilege.md                   ← princípio do menor privilégio
│
├── modulo-3-vpc/
│   ├── writeups/
│   │   └── vpc-guide.md                         ← VPC, subnets, route tables, IGW
│   └── desafios/
│       └── vpc-do-zero.md                       ← criar VPC com subnet pública
│
├── modulo-4-ec2/
│   ├── scripts/
│   │   └── launch-ec2.sh                        ← subindo instância via CLI
│   ├── writeups/
│   │   └── ec2-guide.md                         ← tipos, AMIs, key pairs, Security Groups
│   └── desafios/
│       └── servidor-web-ec2.md                  ← nginx na EC2 com security group
│
├── modulo-5-s3/
│   ├── scripts/
│   │   └── s3-ops.sh                            ← upload, download, sync via CLI
│   ├── writeups/
│   │   └── s3-guide.md                          ← buckets, políticas, classes de storage
│   └── desafios/
│       └── static-site-s3.md                    ← site estático hospedado no S3
│
├── modulo-6-seguranca/
│   ├── writeups/
│   │   └── security-guide.md                    ← security groups, NACLs, CloudTrail
│   └── desafios/
│       └── hardening-ec2.md                     ← EC2 segura + SG bem configurado
│
└── cheatsheets/
    ├── awscli-essencial.md                      ← referência rápida de comandos AWS CLI
    └── troubleshooting.md                       ← erros comuns e como resolver
```

---

## 📚 Módulos em detalhe

### Módulo 1 — Fundamentos & Setup do ambiente
**Status:** ✅ Concluído

Instalação do ambiente de estudo com LocalStack, AWS CLI e awslocal. Primeiro contato com a CLI da AWS criando um bucket S3.

| Entrega | Tipo | Descrição |
|---|---|---|
| `setup-localstack.md` | Writeup | Instalação completa do ambiente de estudo |

---

### Módulo 2 — IAM — Controle de acesso
**Status:** ✅ Concluído

Gerenciamento de identidades e acessos — o coração da segurança na AWS. Criação de usuários, grupos e políticas via CLI. Paralelo direto com `chmod` e grupos do Linux.

| Entrega | Tipo | Descrição |
|---|---|---|
| `iam-guide.md` | Writeup | Users, groups, policies e ARN explicados |
| `criar-politica.sh` | Script | Automatiza criação de usuário, grupo e política |
| `least-privilege.md` | Desafio | Aplicando o princípio do menor privilégio |

**Conceitos cobertos:**
- IAM User, Group, Policy e Role — e o paralelo com Linux
- Managed policies da AWS vs custom policies
- Estrutura de um documento de política JSON (`Effect`, `Action`, `Resource`)
- ARN — endereço único de qualquer recurso na AWS
- Princípio do menor privilégio — cada identidade recebe só o que precisa
- Por que políticas no grupo são preferíveis a políticas diretas no usuário

---

### Módulo 3 — VPC — Rede na nuvem
**Status:** ⏳ Planejado

Redes virtuais privadas na AWS — subnets, tabelas de roteamento e internet gateway.

| Entrega | Tipo | Descrição |
|---|---|---|
| `vpc-guide.md` | Writeup | VPC, subnets públicas e privadas |
| `vpc-do-zero.md` | Desafio | Criar VPC completa via CLI |

---

### Módulo 4 — EC2 — Servidores virtuais
**Status:** ⏳ Planejado

Instâncias EC2, tipos de máquina, AMIs, key pairs e security groups. Equivalente ao nginx + systemd do Linux.

| Entrega | Tipo | Descrição |
|---|---|---|
| `launch-ec2.sh` | Script | Sobe instância EC2 via CLI |
| `ec2-guide.md` | Writeup | Tipos de instância, AMIs, key pairs |
| `servidor-web-ec2.md` | Desafio | nginx na EC2 com security group correto |

---

### Módulo 5 — S3 — Armazenamento de objetos
**Status:** ⏳ Planejado

Buckets, objetos, políticas de acesso e classes de armazenamento. Equivalente ao backup rotativo do Linux.

| Entrega | Tipo | Descrição |
|---|---|---|
| `s3-ops.sh` | Script | Upload, download e sync via CLI |
| `s3-guide.md` | Writeup | Buckets, políticas e classes de storage |
| `static-site-s3.md` | Desafio | Hospedar site estático no S3 |

---

### Módulo 6 — Segurança
**Status:** ⏳ Planejado

Security Groups, NACLs, CloudTrail e boas práticas de segurança na AWS.

| Entrega | Tipo | Descrição |
|---|---|---|
| `security-guide.md` | Writeup | SGs, NACLs, CloudTrail explicados |
| `hardening-ec2.md` | Desafio | EC2 endurecida com SG bem configurado |

---

## 🛠️ Ferramentas utilizadas

| Ferramenta | Uso |
|---|---|
| `localstack` | Simulador de serviços AWS local e gratuito |
| `aws` / `awslocal` | AWS CLI — interface de linha de comando da AWS |
| `docker` | Container que executa o LocalStack |
| `iam` | Controle de identidade e acesso |
| `s3` | Armazenamento de objetos |
| `ec2` | Servidores virtuais na nuvem |
| `vpc` | Rede virtual privada |

---

## 📖 Como ler os writeups

Cada writeup segue esta estrutura:

1. **Objetivo** — o que foi aprendido/resolvido
2. **Contexto** — por que isso importa para um sysadmin/cloud engineer
3. **Passo a passo** — comandos executados com explicação de cada flag
4. **Erros que cometi** — o que deu errado e como resolvi
5. **Resultado** — o que foi entregue/configurado
6. **Referências** — documentação oficial e fontes usadas

---

## 🚀 Como reproduzir o ambiente

### Pré-requisitos

- Docker instalado
- Python 3.x e pip3
- Conta gratuita em [localstack.cloud](https://app.localstack.cloud)

### Instalação

```bash
# AWS CLI oficial
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install

# awslocal e localstack CLI
pip3 install awscli-local localstack --break-system-packages

# Adicionar ao PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Subindo o LocalStack

```bash
export LOCALSTACK_AUTH_TOKEN=seu-token-aqui

docker run -d \
  --name localstack \
  -p 4566:4566 \
  -e LOCALSTACK_AUTH_TOKEN=$LOCALSTACK_AUTH_TOKEN \
  localstack/localstack
```

### Verificando

```bash
curl http://localhost:4566/_localstack/health
awslocal iam list-users
```

> **Atenção:** o token do LocalStack é pessoal — nunca commite no repositório. Use variáveis de ambiente ou um arquivo `.env` no `.gitignore`.

---

## 📈 Progresso

- [x] Repositório criado e estruturado
- [x] Módulo 1 concluído — ambiente configurado
- [x] Módulo 2 concluído — IAM
- [ ] Módulo 3 concluído — VPC
- [ ] Módulo 4 concluído — EC2
- [ ] Módulo 5 concluído — S3
- [ ] Módulo 6 concluído — Segurança

---

## 📬 Contato

Feito por **[seu nome]** — estudando AWS para administração de infraestrutura em nuvem.  
Aberto a feedbacks, sugestões e conexões!

[![LinkedIn](https://img.shields.io/badge/LinkedIn-blue?style=flat&logo=linkedin)](https://linkedin.com/in/seu-perfil)
[![GitHub](https://img.shields.io/badge/GitHub-black?style=flat&logo=github)](https://github.com/johnthesec)

---

*Última atualização: 2026-04-22*
