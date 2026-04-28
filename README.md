# ☁️ AWS Cloud Practitioner Portfolio

> Repositório de aprendizado prático em computação em nuvem com AWS.  
> Cada módulo contém scripts funcionais, writeups explicativos e recursos criados via CLI.

---

## 👤 Sobre este repositório

Estou construindo habilidades reais de administração em nuvem de forma progressiva e documentada. Este portfólio registra minha evolução — do ambiente local com LocalStack até infraestrutura real na AWS Free Tier.

**Objetivo final:** dominar os serviços core da AWS usados por cloud administrators no dia a dia, com evidências concretas de cada etapa.

---

## 🗺️ Roadmap de aprendizado

```
Módulo 1 → Ambiente & S3 básico          ✅ Concluído
Módulo 2 → IAM — Identidade e acesso     ✅ Concluído
Módulo 3 → VPC — Rede privada na nuvem   ✅ Concluído
Módulo 4 → EC2 — Máquinas virtuais       ⏳ Planejado
Módulo 5 → S3 avançado                   ⏳ Planejado
Módulo 6 → RDS — Banco de dados          ⏳ Planejado
Módulo 7 → Projeto integrador            ⏳ Planejado
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
│       └── setup-localstack.md                  ← ambiente AWS local configurado
│
├── modulo-2-iam/
│   └── writeups/
│       └── iam-guide.md                         ← users, groups, policies via CLI
│
├── modulo-3-vpc/
│   ├── scripts/
│   │   └── vpc-setup.sh                         ← cria e destrói infraestrutura de rede
│   └── writeups/
│       └── vpc-guide.md                         ← VPC, subnets, IGW, route tables
│
├── modulo-4-ec2/
│   ├── scripts/
│   │   └── (em breve)
│   └── writeups/
│       └── (em breve)
│
├── modulo-5-s3/
│   └── writeups/
│       └── (em breve)
│
├── modulo-6-rds/
│   └── writeups/
│       └── (em breve)
│
└── modulo-7-projeto/
    └── README.md                                ← arquitetura completa integrada
```

---

## 📚 Módulos em detalhe

### Módulo 1 — Ambiente & S3 básico
**Status:** ✅ Concluído

Configuração do ambiente de desenvolvimento AWS local com LocalStack, AWS CLI e primeiro contato com S3.

| Entrega | Tipo | Descrição |
|---|---|---|
| `setup-localstack.md` | Writeup | Instalação e configuração do LocalStack |

**Conceitos cobertos:**
- Docker como base do LocalStack
- AWS CLI v2 + `awslocal` wrapper apontando para `localhost:4566`
- `LOCALSTACK_AUTH_TOKEN` salvo em `.bashrc`
- DNS do Docker corrigido em `/etc/docker/daemon.json`
- Primeiro bucket S3 criado: `meu-primeiro-bucket`

---

### Módulo 2 — IAM — Identidade e controle de acesso
**Status:** ✅ Concluído

Criação e gerenciamento de identidades, grupos e políticas de acesso via CLI.

| Entrega | Tipo | Descrição |
|---|---|---|
| `iam-guide.md` | Writeup | Users, groups, managed e custom policies |

**Conceitos cobertos:**
- IAM User (`dev-joao`) e Group (`desenvolvedores`)
- Managed policy `AmazonS3ReadOnlyAccess` anexada ao grupo
- Custom policy `S3RestritaBucket` criada em JSON e anexada ao usuário
- ARN — Amazon Resource Name
- Princípio do menor privilégio

---

### Módulo 3 — VPC — Rede privada na nuvem
**Status:** ✅ Concluído

Criação de uma VPC completa com subnets pública e privada, Internet Gateway e roteamento configurado via CLI.

| Entrega | Tipo | Descrição |
|---|---|---|
| `vpc-setup.sh` | Script | Cria e destrói infraestrutura de rede com flags |
| `vpc-guide.md` | Writeup | VPC, CIDR, subnets, IGW, route tables |

**Conceitos cobertos:**
- VPC como rede privada isolada na AWS
- CIDR — notação de blocos de IP (`/16` = 65.536 endereços, `/24` = 256 endereços)
- Subnet pública vs privada — propósito e configuração
- Internet Gateway — porta de saída para a internet, precisa ser criado e anexado
- Route Table — roteamento de tráfego por subnet (`0.0.0.0/0` → IGW)
- `MapPublicIpOnLaunch` — IP público automático em instâncias EC2
- LocalStack sem persistência — estado perdido ao reiniciar o container

---

### Módulo 4 — EC2 — Máquinas virtuais
**Status:** ⏳ Planejado

Criação de instâncias EC2, key pairs, AMIs e acesso via SSH dentro da VPC criada no módulo 3.

| Entrega | Tipo | Descrição |
|---|---|---|
| `ec2-setup.sh` | Script | Sobe instância EC2 na subnet pública |
| `ec2-guide.md` | Writeup | Instâncias, AMIs, key pairs, user data |

---

### Módulo 5 — S3 avançado
**Status:** ⏳ Planejado

Bucket policies, versionamento, prefixos e controle de acesso granular.

| Entrega | Tipo | Descrição |
|---|---|---|
| `s3-guide.md` | Writeup | Policies de bucket, versionamento, ACLs |

---

### Módulo 6 — RDS — Banco de dados gerenciado
**Status:** ⏳ Planejado

Instâncias de banco de dados na subnet privada, subnet groups e acesso controlado por security groups.

| Entrega | Tipo | Descrição |
|---|---|---|
| `rds-guide.md` | Writeup | Instâncias MySQL, subnet groups, acesso privado |

---

### Módulo 7 — Projeto integrador
**Status:** ⏳ Planejado

Arquitetura completa combinando todos os módulos anteriores: VPC + EC2 + RDS + S3 + IAM.

| Entrega | Tipo | Descrição |
|---|---|---|
| `README.md` | Documento | Diagrama e documentação da arquitetura |
| `infra-setup.sh` | Script | Provisiona toda a infraestrutura do zero |

---

## 🛠️ Ferramentas utilizadas

| Ferramenta | Uso |
|---|---|
| `awslocal` | Wrapper do AWS CLI apontando para o LocalStack |
| `aws cli v2` | Interface de linha de comando da AWS |
| `LocalStack` | Simulador AWS local via Docker |
| `Docker` | Container do LocalStack |
| `ec2` | Serviço de VPC, subnets e instâncias |
| `iam` | Gerenciamento de identidade e acesso |
| `s3` | Armazenamento de objetos |

---

## 📖 Como ler os writeups

Cada writeup segue esta estrutura:

1. **Objetivo** — o que foi aprendido/resolvido
2. **Contexto** — por que isso importa para um cloud admin
3. **Ambiente** — ferramentas e versões utilizadas
4. **Passo a passo** — comandos executados com explicação de cada flag
5. **Erros que cometi** — o que deu errado e como resolvi
6. **Resultado** — o que foi entregue/configurado
7. **Referências** — documentação e fontes usadas

---

## 🚀 Como usar os scripts

Clone o repositório e dê permissão de execução antes de rodar qualquer script:

```bash
git clone https://github.com/johnthesec/aws-cloud-practitioner.git
cd aws-cloud-practitioner
```

**Subindo o ambiente LocalStack:**
```bash
sudo service docker start
docker start localstack
sleep 15 && curl -s http://localhost:4566/_localstack/health | python3 -m json.tool | grep ec2
```

**Módulo 3 — Criando a infraestrutura de rede:**
```bash
chmod +x modulo-3-vpc/scripts/vpc-setup.sh
./modulo-3-vpc/scripts/vpc-setup.sh        # cria tudo
./modulo-3-vpc/scripts/vpc-setup.sh -d     # destrói tudo
./modulo-3-vpc/scripts/vpc-setup.sh -h     # ajuda
```

> **Atenção:** o LocalStack não persiste estado entre reinicializações do container. Ao reiniciar, rode o script novamente para recriar a infraestrutura.

---

## 📈 Progresso

- [x] Módulo 1 — Ambiente & S3 básico concluído
- [x] Módulo 2 — IAM concluído
- [x] Módulo 3 — VPC concluído
- [ ] Módulo 4 — EC2
- [ ] Módulo 5 — S3 avançado
- [ ] Módulo 6 — RDS
- [ ] Módulo 7 — Projeto integrador

---

## 📬 Contato

Feito por **João** — estudando AWS para administração de servidores em nuvem.  
Aberto a feedbacks, sugestões e conexões!

[![LinkedIn](https://img.shields.io/badge/LinkedIn-blue?style=flat&logo=linkedin)](https://linkedin.com/in/seu-perfil)
[![GitHub](https://img.shields.io/badge/GitHub-black?style=flat&logo=github)](https://github.com/johnthesec)

---

*Última atualização: 2026-04-28*
