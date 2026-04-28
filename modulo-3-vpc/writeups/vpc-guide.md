# VPC — Rede privada na nuvem

> **Módulo:** Módulo 3 — VPC
> **Tipo:** `writeup`
> **Dificuldade:** Iniciante
> **Data:** 2026-04-28

---

## 🎯 Objetivo

Criar uma VPC completa na AWS com subnets pública e privada, Internet Gateway e route table configurada — simulando a infraestrutura de rede base de qualquer servidor real na nuvem.

---

## 🧠 Contexto

Na AWS, nenhum recurso existe fora de uma VPC. Antes de subir um servidor EC2 ou um banco de dados RDS, é preciso ter uma rede configurada corretamente. Uma VPC mal configurada é uma das causas mais comuns de falhas de segurança em ambientes cloud — um banco de dados em subnet pública, por exemplo, fica exposto à internet inteira.

Saber criar e segmentar redes é pré-requisito para tudo que vem depois no portfólio AWS.

---

## ⚙️ Ambiente

| Item | Valor |
|---|---|
| Sistema operacional | Ubuntu 24.04 LTS (WSL2) |
| Usuário | `john` |
| Simulador AWS | LocalStack 2026.3.0 (Docker, porta 4566) |
| CLI | AWS CLI v2 + `awslocal` wrapper |
| Pré-requisitos | Docker rodando, container `localstack` ativo |

---

## 📋 Passo a passo

### Passo 1 — Verificando o ambiente

Antes de qualquer comando, garantir que o LocalStack está de pé e o serviço EC2 está disponível:

```bash
docker start localstack
sleep 15
curl -s http://localhost:4566/_localstack/health | python3 -m json.tool | grep ec2
```

**Saída esperada:**
```
"ec2": "available",
```

O LocalStack não persiste estado entre reinicializações do container. Toda vez que o container reinicia, todos os recursos criados anteriormente são perdidos. Por isso usamos variáveis de shell para capturar os IDs e recriar rapidamente quando necessário.

---

### Passo 2 — Criando a VPC

A VPC é o recurso raiz — todos os outros recursos de rede ficam dentro dela.

```bash
VPC_ID=$(awslocal ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=vpc-portfolio}]' \
  --query 'Vpc.VpcId' \
  --output text)

echo $VPC_ID
```

**O que cada parte faz:**
- `--cidr-block 10.0.0.0/16` — bloco de IPs da VPC inteira. `/16` fixa os dois primeiros octetos (`10.0`), deixando 65.536 endereços disponíveis para distribuir entre subnets
- `--tag-specifications` — adiciona tag de nome ao recurso no momento da criação
- `--query 'Vpc.VpcId'` — filtra só o ID da saída JSON
- `--output text` — retorna texto puro em vez de JSON, ideal para salvar em variável

**Saída:**
```
vpc-e370874b131574f54
```

---

### Passo 3 — Criando as subnets

Duas subnets com propósitos diferentes:

- **Pública** `10.0.1.0/24` — onde ficará o servidor web (EC2), acessível pela internet
- **Privada** `10.0.2.0/24` — onde ficará o banco de dados, isolado da internet

```bash
# Subnet pública
SUBNET_PUB=$(awslocal ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.1.0/24 \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=subnet-publica}]' \
  --query 'Subnet.SubnetId' \
  --output text)

# Subnet privada
SUBNET_PRIV=$(awslocal ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.2.0/24 \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=subnet-privada}]' \
  --query 'Subnet.SubnetId' \
  --output text)
```

O `/24` fixa os três primeiros octetos, deixando 256 endereços por subnet (251 utilizáveis — a AWS reserva 5 por subnet).

**Habilitando IP público automático na subnet pública:**

```bash
awslocal ec2 modify-subnet-attribute \
  --subnet-id $SUBNET_PUB \
  --map-public-ip-on-launch
```

Por padrão, `MapPublicIpOnLaunch` é `false`. Sem esse ajuste, instâncias EC2 criadas na subnet pública não receberiam IP público automaticamente.

**Verificação:**
```bash
awslocal ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'Subnets[*].{ID:SubnetId,CIDR:CidrBlock,Nome:Tags[0].Value,IP_Publico:MapPublicIpOnLaunch}' \
  --output table
```

**Saída:**
```
-----------------------------------------------------------------------------
|                              DescribeSubnets                              |
+-------------+----------------------------+-------------+------------------+
|    CIDR     |            ID              | IP_Publico  |      Nome        |
+-------------+----------------------------+-------------+------------------+
|  10.0.2.0/24|  subnet-5d3f268bd078b13ac  |  False      |  subnet-privada  |
|  10.0.1.0/24|  subnet-afcf0fa2b52be3d3c  |  True       |  subnet-publica  |
+-------------+----------------------------+-------------+------------------+
```

---

### Passo 4 — Criando o Internet Gateway

O Internet Gateway é a porta de saída da VPC para a internet. Sem ele, nenhum recurso dentro da VPC consegue se comunicar com o mundo externo.

```bash
IGW_ID=$(awslocal ec2 create-internet-gateway \
  --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=igw-portfolio}]' \
  --query 'InternetGateway.InternetGatewayId' \
  --output text)
```

Criar o gateway não é suficiente — ele precisa ser **anexado** a uma VPC específica:

```bash
awslocal ec2 attach-internet-gateway \
  --internet-gateway-id $IGW_ID \
  --vpc-id $VPC_ID
```

Sem saída = sucesso. Para confirmar:

```bash
awslocal ec2 describe-internet-gateways \
  --internet-gateway-ids $IGW_ID \
  --query 'InternetGateways[0].{ID:InternetGatewayId,VPC:Attachments[0].VpcId,Estado:Attachments[0].State}' \
  --output table
```

**Saída:**
```
-----------------------------------------------------------------
|                   DescribeInternetGateways                    |
+-----------+-------------------------+-------------------------+
|  Estado   |           ID            |           VPC           |
+-----------+-------------------------+-------------------------+
|  available|  igw-287e6b0024659dada  |  vpc-e370874b131574f54  |
+-----------+-------------------------+-------------------------+
```

---

### Passo 5 — Criando a Route Table pública

A VPC cria automaticamente uma route table padrão, mas ela não tem rota para a internet. Criamos uma route table específica para a subnet pública:

```bash
RTB_ID=$(awslocal ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=rtb-publica}]' \
  --query 'RouteTable.RouteTableId' \
  --output text)
```

**Adicionando rota para a internet:**

```bash
awslocal ec2 create-route \
  --route-table-id $RTB_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID
```

`0.0.0.0/0` significa "qualquer destino" — tráfego que não for interno à VPC será enviado para o IGW.

**Saída:**
```json
{
    "Return": true
}
```

**Associando a route table à subnet pública:**

```bash
awslocal ec2 associate-route-table \
  --route-table-id $RTB_ID \
  --subnet-id $SUBNET_PUB
```

Sem essa associação, a subnet continuaria usando a route table padrão da VPC, sem rota para a internet.

---

## 💡 Conceitos aprendidos

- **VPC** — rede privada isolada dentro da AWS; todos os recursos de compute ficam dentro dela
- **CIDR** — notação para definir blocos de IP; `/16` = 65.536 endereços, `/24` = 256 endereços
- **Subnet pública** — tem rota para a internet via IGW; usada para servidores web
- **Subnet privada** — sem rota para a internet; usada para bancos de dados e serviços internos
- **Internet Gateway** — porta de saída da VPC para a internet; precisa ser criado e anexado à VPC
- **Route Table** — tabela de roteamento que define para onde vai o tráfego de cada subnet
- **`0.0.0.0/0`** — rota padrão; captura qualquer tráfego que não bate em rotas mais específicas
- **`MapPublicIpOnLaunch`** — atributo da subnet que controla se EC2s recebem IP público automaticamente
- **`--query`** — filtro JMESPath do AWS CLI para extrair campos específicos do JSON de retorno
- **Estado sem persistência** — o LocalStack perde todos os recursos ao reiniciar o container

---

## ⚠️ Erros que cometi (e como resolvi)

**Erro 1 — Typo em `ResourceType`:**
```
Unknown parameter in TagSpecifications[0]: "ResourseType"
```
Causa: digitei `ResourseType` em vez de `ResourceType`.
Solução: corrigi a ortografia. O AWS CLI é case-sensitive e valida os nomes dos parâmetros.

**Erro 2 — Typo em `Value`:**
```
Unknown parameter in TagSpecifications[0].Tags[0]: "value"
```
Causa: digitei `value` com `v` minúsculo em vez de `Value`.
Solução: corrigi para `Value` com V maiúsculo. Parâmetros dentro de estruturas JSON também são case-sensitive.

**Erro 3 — Typo em `--vpc-id`:**
```
the following arguments are required: --vpc-id
```
Causa: digitei `--vcp-id` com `c` e `p` trocados.
Solução: corrigi para `--vpc-id`.

**Erro 4 — LocalStack perdeu estado após reinicialização:**
```
InvalidVpcID.NotFound: VpcID vpc-58e68abfa3d96f7e3 does not exist
```
Causa: o container do LocalStack reiniciou e perdeu todos os recursos criados anteriormente. O LocalStack não persiste estado por padrão.
Solução: recriei todos os recursos do zero. A partir daí passei a capturar os IDs em variáveis de shell para facilitar a recriação.

**Erro 5 — Case-sensitive em query JMESPath:**
```
Estado: None  |  VPC: None
```
Causa: usei `attachments` com `a` minúsculo na query `--query` em vez de `Attachments`.
Solução: corrigi para `Attachments` com A maiúsculo. Queries JMESPath respeitam o case dos campos JSON retornados pela API.

---

## ✅ Resultado final

Arquitetura de rede completa criada via CLI:

```
VPC  10.0.0.0/16  (vpc-portfolio)
│
├── subnet-publica   10.0.1.0/24  → MapPublicIpOnLaunch: true
│       └── rtb-publica: 0.0.0.0/0 → igw-portfolio
│
└── subnet-privada   10.0.2.0/24  → MapPublicIpOnLaunch: false
        └── route table padrão (sem rota para internet)
│
└── igw-portfolio  (anexado à VPC, estado: available)
```

---

## 📎 Arquivos relacionados

| Arquivo | Descrição |
|---|---|
| `scripts/vpc-setup.sh` | cria e destrói toda a infraestrutura de rede com um único comando |

---

## 🔗 Referências

- `awslocal ec2 help` — referência completa dos subcomandos EC2
- [Documentação AWS VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)
- [CIDR calculadora](https://cidr.xyz) — útil para visualizar blocos de IP
