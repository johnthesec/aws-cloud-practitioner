# 🐧 Linux SysAdmin Portfolio

> Repositório de aprendizado prático em administração de servidores Linux.  
> Cada fase contém scripts funcionais, writeups explicativos e desafios resolvidos.

---

## 👤 Sobre este repositório

Estou construindo habilidades reais de administração de servidores Linux de forma progressiva e documentada. Este portfólio registra minha evolução — do terminal básico até automação e deploy de servidores completos.

**Objetivo final:** dominar as ferramentas e práticas usadas por sysadmins no dia a dia, com evidências concretas de cada etapa.

---

## 🗺️ Roadmap de aprendizado

```
Fase 1 → Fundamentos do terminal          ✅ Concluída
Fase 2 → Arquivos, usuários e permissões  ✅ Concluída
Fase 3 → Rede, serviços e processos       ✅ Concluída
Fase 4 → Automação e projetos finais
```

---

## 📁 Estrutura do repositório

```
linux-sysadmin-portfolio/
│
├── README.md                                ← você está aqui
│
├── fase-1-fundamentos/
│   ├── scripts/
│   │   └── backup.sh                        ← backup de configs com timestamp
│   ├── writeups/
│   │   └── filesystem-linux.md              ← hierarquia de diretórios explicada
│   └── desafios/
│       └── find-grep-pipes.md               ← localização de arquivos com find e grep
│
├── fase-2-permissoes/
│   ├── scripts/
│   │   ├── gerenciar-acesso.sh              ← cria grupos, aplica e revoga permissões
│   │   └── audit-permissions.sh             ← auditoria de permissões inseguras
│   ├── writeups/
│   │   └── writeup-permissoes.md            ← chmod, chown, grupos, cadeia de acesso
│   └── desafios/
│       └── desafio-auditoria.md             ← auditoria de arquivos world-writable e SUID
│
├── fase-3-rede-servicos/
│   ├── scripts/
│   │   └── health-check.sh                  ← monitor de RAM, disco e serviços
│   ├── configs/
│   │   └── nginx.conf                       ← configuração comentada do nginx
│   ├── writeups/
│   │   └── writeup-fase3.md                 ← nginx, systemd, ufw e health check
│   └── desafios/
│       └── ssh-hardening.md                 ← hardening de SSH com chave ED25519
│
├── fase-4-automacao/
│   ├── scripts/
│   │   └── backup-rotativo.sh               ← backup diário com rotação de 7 dias
│   ├── configs/
│   │   └── crontab.txt                      ← agendamentos configurados
│   └── lamp-setup/
│       ├── install.sh                       ← instalação automatizada do LAMP
│       ├── vhost.conf                       ← virtual host Apache configurado
│       └── README.md                        ← guia completo do projeto final
│
└── cheatsheets/
    ├── comandos-essenciais.md               ← referência rápida de comandos
    └── troubleshooting.md                   ← erros comuns e como resolver
```

---

## 📚 Fases em detalhe

### Fase 1 — Fundamentos do terminal
**Status:** ✅ Concluída

Foco em navegação, leitura de arquivos, uso de `find`, `grep` e pipes. Primeiro contato com scripting Bash.

| Entrega | Tipo | Descrição |
|---|---|---|
| `backup.sh` | Script | Copia arquivos de config com timestamp |
| `filesystem-linux.md` | Writeup | Explica /etc, /var, /home, /bin |
| `find-grep-pipes.md` | Desafio | Localiza logs e arquivos por conteúdo |

---

### Fase 2 — Arquivos, Usuários & Permissões
**Status:** ✅ Concluída

Leitura e modificação de permissões com `chmod` e `chown`, gerenciamento de grupos, controle de acesso por cadeia de diretórios, revogação de acessos e auditoria de segurança.

| Entrega | Tipo | Descrição |
|---|---|---|
| `gerenciar-acesso.sh` | Script | Cria grupos, aplica e revoga permissões com flags |
| `audit-permissions.sh` | Script | Auditoria de arquivos world-writable e SUID |
| `writeup-permissoes.md` | Writeup | chmod, chown, notação octal, cadeia de acesso |
| `desafio-auditoria.md` | Desafio | Auditoria de permissões inseguras com find |

---

### Fase 3 — Rede, Serviços & Processos
**Status:** ✅ Concluída

nginx, systemd, firewall com `ufw`, monitoramento de recursos e hardening de SSH.

| Entrega | Tipo | Descrição |
|---|---|---|
| `health-check.sh` | Script | Monitor de RAM, disco e serviços com flags |
| `nginx.conf` | Config | Configuração comentada do nginx |
| `writeup-fase3.md` | Writeup | nginx, systemd, ufw e health check |
| `ssh-hardening.md` | Desafio | Hardening de SSH com chave ED25519 |

**Conceitos cobertos:**
- Modelo master/worker do nginx
- Diagnóstico de conflito de porta com `ss -tlnp`
- Controle de serviços com `systemctl` — start, stop, reload, restart, enable, disable
- Diferença entre `reload` (mantém conexões) e `restart` (recria tudo)
- Diferença entre `stop` (para agora) e `disable` (impede boot automático)
- Firewall com `ufw` — política `deny incoming` por padrão
- SSH restrito por IP — evita ataques de força bruta
- Hardening de SSH — chave ED25519, sem senha, sem root login

---

### Fase 4 — Automação & Projeto Final
**Status:** 🔜 Próxima fase

`cron`, scripts avançados e deploy de um servidor LAMP completo como projeto integrador.

| Entrega | Tipo | Descrição |
|---|---|---|
| `backup-rotativo.sh` | Script | Backup diário com retenção de 7 dias |
| `lamp-setup/` | Projeto | Servidor Linux+Apache+MySQL+PHP do zero |

---

## 🛠️ Ferramentas utilizadas

| Ferramenta | Uso |
|---|---|
| `bash` | Scripting e automação |
| `find` / `grep` | Busca e filtragem de arquivos |
| `chmod` / `chown` | Controle de permissões |
| `groupadd` / `usermod` / `gpasswd` | Gerenciamento de usuários e grupos |
| `nginx` | Servidor web |
| `systemctl` | Gerenciamento de serviços |
| `ufw` | Firewall e controle de portas |
| `ss` | Monitoramento de portas e conexões |
| `ssh` / `ssh-keygen` | Acesso remoto seguro e geração de chaves |
| `cron` | Agendamento de tarefas |

---

## 📖 Como ler os writeups

Cada writeup segue esta estrutura:

1. **Objetivo** — o que foi aprendido/resolvido
2. **Contexto** — por que isso importa para um sysadmin
3. **Passo a passo** — comandos executados com explicação de cada flag
4. **Erros que cometi** — o que deu errado e como resolvi
5. **Resultado** — o que foi entregue/configurado
6. **Referências** — man pages e fontes usadas

---

## 🚀 Como usar os scripts

Clone o repositório e dê permissão de execução antes de rodar qualquer script:

```bash
git clone https://github.com/seu-usuario/linux-sysadmin-portfolio.git
cd linux-sysadmin-portfolio

# Health check do servidor
chmod +x fase-3-rede-servicos/scripts/health-check.sh
./fase-3-rede-servicos/scripts/health-check.sh

# Com flags
./fase-3-rede-servicos/scripts/health-check.sh -s   # só serviços
./fase-3-rede-servicos/scripts/health-check.sh -r   # só recursos
```

> **Atenção:** scripts das fases 2 e 3 envolvem criação de usuários e alteração de serviços. Leia o writeup correspondente antes de executar em produção.

---

## 📈 Progresso

- [x] Repositório criado e estruturado
- [x] Fase 1 concluída
- [x] Fase 2 concluída
- [x] Fase 3 concluída
- [ ] Fase 4 e projeto final concluídos

---

## 📬 Contato

Feito por **[seu nome]** — estudando Linux para administração de servidores.  
Aberto a feedbacks, sugestões e conexões!

[![LinkedIn](https://img.shields.io/badge/LinkedIn-blue?style=flat&logo=linkedin)](https://linkedin.com/in/seu-perfil)
[![GitHub](https://img.shields.io/badge/GitHub-black?style=flat&logo=github)](https://github.com/seu-usuario)

---

*Última atualização: 2026-04-08*
