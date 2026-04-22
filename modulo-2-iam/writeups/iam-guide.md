# IAM — Controle de acesso na AWS

> **Módulo:** Módulo 2 — IAM — Controle de acesso
> **Tipo:** `writeup`
> **Dificuldade:** Iniciante
> **Data:** 2026-04-22

---

## 🎯 Objetivo

Entender como o IAM (Identity and Access Management) controla o acesso aos serviços da AWS — criando usuários, grupos e políticas via CLI, e aplicando o princípio do menor privilégio.

---

## 🧠 Contexto

Tudo que acontece na AWS passa pelo IAM. Criar um bucket S3, subir uma instância EC2, acessar um banco de dados — cada ação precisa de uma permissão explícita. Sem ela, o comando é negado.

O paralelo com Linux é direto:

| Linux | AWS IAM |
|---|---|
| Usuário do sistema (`useradd`) | IAM User |
| Grupo (`groupadd`) | IAM Group |
| Permissão (`chmod`) | IAM Policy |
| `sudo` | IAM Role |

A diferença principal: no Linux as permissões são definidas por bits (r/w/x). Na AWS são documentos JSON que descrevem exatamente quais ações são permitidas em quais recursos.

---

## ⚙️ Ambiente

| Item | Valor |
|---|---|
| Sistema operacional | Ubuntu 24.04 LTS (WSL) |
| Usuário utilizado | `john` |
| Ambiente AWS | LocalStack 2026.3.0 (local) |
| CLI utilizada | `awslocal` (aponta para localhost:4566) |

---

## 📋 Passo a passo

### Passo 1 — Verificando o ambiente

Antes de começar, confirmamos que o LocalStack estava respondendo e a lista de usuários estava vazia:

```bash
awslocal iam list-users
```

**Saída:**
```json
{
    "Users": []
}
```

---

### Passo 2 — Criando um usuário IAM

**Cenário:** um desenvolvedor chamado `dev-joao` precisa de acesso ao S3. Criamos a identidade dele:

```bash
awslocal iam create-user --user-name dev-joao
```

**Saída:**
```json
{
    "User": {
        "Path": "/",
        "UserName": "dev-joao",
        "UserId": "AIDAQAAAAAAADQXA6BWQR",
        "Arn": "arn:aws:iam::000000000000:user/dev-joao",
        "CreateDate": "2026-04-22T14:19:59.946919+00:00"
    }
}
```

**O que cada campo significa:**
- `UserName` — o nome definido na criação
- `UserId` — ID único gerado pela AWS, imutável
- `Arn` — endereço completo do recurso. Formato: `arn:aws:iam::CONTA:user/NOME`. Na AWS real, o número da conta seria o ID da sua conta — o LocalStack usa `000000000000`
- `CreateDate` — timestamp de criação

---

### Passo 3 — Criando um grupo

Grupos organizam usuários com o mesmo perfil de acesso. Em vez de aplicar permissões um a um, você aplica no grupo e todos os membros herdam:

```bash
awslocal iam create-group --group-name desenvolvedores
```

**Saída:**
```json
{
    "Group": {
        "Path": "/",
        "GroupName": "desenvolvedores",
        "GroupId": "AGPAQAAAAAAADG7BCCLX4",
        "Arn": "arn:aws:iam::000000000000:group/desenvolvedores",
        "CreateDate": "2026-04-22T14:24:47.819167+00:00"
    }
}
```

---

### Passo 4 — Adicionando o usuário ao grupo

Equivalente ao `usermod -aG` do Linux:

```bash
awslocal iam add-user-to-group \
  --group-name desenvolvedores \
  --user-name dev-joao
```

Sem saída = sucesso. A AWS CLI só retorna algo quando há erro ou dados para exibir.

**Confirmação:**

```bash
awslocal iam get-group --group-name desenvolvedores
```

**Saída:**
```json
{
    "Users": [
        {
            "UserName": "dev-joao",
            "UserId": "AIDAQAAAAAAADQXA6BWQR",
            "Arn": "arn:aws:iam::000000000000:user/dev-joao",
            "CreateDate": "2026-04-22T14:19:59.946919+00:00"
        }
    ],
    "Group": {
        "GroupName": "desenvolvedores",
        "GroupId": "AGPAQAAAAAAADG7BCCLX4",
        "Arn": "arn:aws:iam::000000000000:group/desenvolvedores",
        "CreateDate": "2026-04-22T14:24:47.819167+00:00"
    }
}
```

---

### Passo 5 — Anexando uma política gerenciada ao grupo

A AWS tem políticas prontas chamadas **managed policies**. Aplicamos a `AmazonS3ReadOnlyAccess` ao grupo — que permite listar e baixar objetos S3, mas não criar nem deletar nada:

```bash
awslocal iam attach-group-policy \
  --group-name desenvolvedores \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
```

**O que cada parte faz:**
- `attach-group-policy` — anexa uma política a um grupo
- `--policy-arn` — endereço da política. O prefixo `arn:aws:iam::aws:policy/` indica que é uma política gerenciada pela própria AWS

**Confirmação:**

```bash
awslocal iam list-attached-group-policies --group-name desenvolvedores
```

**Saída:**
```json
{
    "AttachedPolicies": [
        {
            "PolicyName": "AmazonS3ReadOnlyAccess",
            "PolicyArn": "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
        }
    ]
}
```

---

### Passo 6 — Criando uma política customizada

As políticas gerenciadas são genéricas. Em produção, criamos políticas específicas para restringir o acesso ao mínimo necessário — princípio do menor privilégio.

Criamos uma política que permite apenas listar e baixar objetos de um bucket específico:

```bash
cat > /tmp/policy-s3-restrita.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::meu-primeiro-bucket",
        "arn:aws:s3:::meu-primeiro-bucket/*"
      ]
    }
  ]
}
EOF
```

**Estrutura do documento JSON:**
- `Version` — versão da linguagem de política. Sempre `2012-10-17`
- `Statement` — lista de regras
- `Effect` — `Allow` (permite) ou `Deny` (nega)
- `Action` — lista de operações permitidas. `s3:ListBucket` lista objetos, `s3:GetObject` baixa objetos
- `Resource` — a quais recursos a regra se aplica. O `/*` no segundo ARN cobre todos os objetos dentro do bucket

**Criando a política na AWS:**

```bash
awslocal iam create-policy \
  --policy-name S3RestritaBucket \
  --policy-document file:///tmp/policy-s3-restrita.json
```

**Saída:**
```json
{
    "Policy": {
        "PolicyName": "S3RestritaBucket",
        "PolicyId": "APMNF8OGR8OOJNSZUALER",
        "Arn": "arn:aws:iam::000000000000:policy/S3RestritaBucket",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "IsAttachable": true,
        "CreateDate": "2026-04-22T15:04:25.241359+00:00"
    }
}
```

`AttachmentCount: 0` — a política existe mas ainda não está anexada a ninguém.

---

### Passo 7 — Anexando a política customizada diretamente ao usuário

Desta vez anexamos direto no usuário para mostrar que as duas formas funcionam:

```bash
awslocal iam attach-user-policy \
  --user-name dev-joao \
  --policy-arn arn:aws:iam::000000000000:policy/S3RestritaBucket
```

**Confirmação:**

```bash
awslocal iam list-attached-user-policies --user-name dev-joao
```

**Saída:**
```json
{
    "AttachedPolicies": [
        {
            "PolicyName": "S3RestritaBucket",
            "PolicyArn": "arn:aws:iam::000000000000:policy/S3RestritaBucket"
        }
    ]
}
```

O `dev-joao` ficou com duas camadas de permissão:
- **Via grupo** `desenvolvedores` → `AmazonS3ReadOnlyAccess` (leitura em todo S3)
- **Direto no usuário** → `S3RestritaBucket` (restrito ao `meu-primeiro-bucket`)

> **Boas práticas:** em produção, o recomendado é aplicar políticas sempre no grupo — nunca direto no usuário. Fica mais fácil auditar e gerenciar quando a equipe cresce.

---

### Passo 8 — Limpeza do ambiente

```bash
# Remove políticas do usuário e do grupo
awslocal iam detach-user-policy \
  --user-name dev-joao \
  --policy-arn arn:aws:iam::000000000000:policy/S3RestritaBucket

awslocal iam detach-group-policy \
  --group-name desenvolvedores \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# Remove usuário do grupo
awslocal iam remove-user-from-group \
  --group-name desenvolvedores \
  --user-name dev-joao

# Deleta usuário, grupo e política customizada
awslocal iam delete-user --user-name dev-joao
awslocal iam delete-group --group-name desenvolvedores
awslocal iam delete-policy \
  --policy-arn arn:aws:iam::000000000000:policy/S3RestritaBucket
```

**Confirmação:**

```bash
awslocal iam list-users
# { "Users": [] }

awslocal iam list-groups
# { "Groups": [] }
```

---

## 💡 Conceitos aprendidos

- **IAM User** — identidade com credenciais. Equivale a um usuário Linux
- **IAM Group** — agrupa usuários para aplicar permissões de uma vez. Equivale ao `groupadd` + `usermod -aG`
- **IAM Policy** — documento JSON que define o que é permitido ou negado. Equivale ao `chmod`
- **Managed Policy** — política pronta e gerenciada pela AWS. Reutilizável em qualquer conta
- **Custom Policy** — política criada pelo próprio usuário, específica para o caso de uso
- **ARN** — endereço único de qualquer recurso na AWS. Formato: `arn:aws:serviço::conta:tipo/nome`
- **`attach-group-policy`** — anexa política a um grupo
- **`attach-user-policy`** — anexa política diretamente a um usuário (evitar em produção)
- **Princípio do menor privilégio** — cada identidade recebe apenas as permissões que precisa, nada além

---

## ⚠️ Erros que cometi (e como resolvi)

Nenhum erro técnico neste módulo — os comandos foram executados sem problemas. O aprendizado principal foi conceitual: entender que políticas diretas no usuário são tecnicamente válidas mas ruins para manutenção em larga escala.

---

## ✅ Resultado final

Ciclo completo de IAM executado via CLI:

```
IAM User:   dev-joao              ← criado com create-user
    ↓ membro de
IAM Group:  desenvolvedores       ← criado com create-group
    ↓ possui
IAM Policy: AmazonS3ReadOnlyAccess ← managed policy da AWS
IAM Policy: S3RestritaBucket       ← custom policy criada no exercício
    ↓ permite
S3: ListBucket + GetObject em meu-primeiro-bucket
```

---

## 📎 Arquivos relacionados

| Arquivo | Descrição |
|---|---|
| `scripts/criar-politica.sh` | script que automatiza a criação de usuário, grupo e política (próxima entrega) |

---

## 🔗 Referências

- [Documentação IAM — AWS](https://docs.aws.amazon.com/iam/)
- [Referência de políticas IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies.html)
- [Lista de managed policies da AWS](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/policy-list.html)
- `awslocal iam help` — referência completa dos comandos IAM via CLI
