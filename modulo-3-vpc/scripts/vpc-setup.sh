#!/bin/bash

# vpc-setup.sh
# Cria uma VPC completa no LocalStack com subnets pública e privada,
# Internet Gateway e route table configurada para acesso à internet.
# Uso: ./vpc-setup.sh
#
# Opcoes:
#   -d    Destruir todos os recursos criados
#   -h    Mostrar ajuda

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warning() { echo -e "${YELLOW}[AVISO]${NC} $1"; }
error()   { echo -e "${RED}[ERRO]${NC} $1"; exit 1; }

# ─── CONFIGURAÇÕES ───────────────────────────────────────────
VPC_CIDR="10.0.0.0/16"
SUBNET_PUB_CIDR="10.0.1.0/24"
SUBNET_PRIV_CIDR="10.0.2.0/24"
ENDPOINT="http://localhost:4566"

mostrar_ajuda() {
    echo ""
    echo "Uso: ./vpc-setup.sh [opcao]"
    echo ""
    echo "Opcoes:"
    echo "  -d    Destruir todos os recursos criados"
    echo "  -h    Mostrar esta ajuda"
    echo ""
    echo "Sem opcao: cria toda a infraestrutura de rede"
    echo ""
}

verificar_localstack() {
    info "Verificando LocalStack..."

    if ! curl -s "$ENDPOINT/_localstack/health" | grep -q '"ec2": "available"'; then
        error "LocalStack nao esta rodando ou EC2 nao esta disponivel. Execute: docker start localstack"
    fi

    success "LocalStack disponivel."
}

criar_vpc() {
    echo ""
    echo "================================================"
    echo "  VPC SETUP — $(date '+%Y-%m-%d %H:%M:%S')"
    echo "================================================"
    echo ""

    verificar_localstack

    # ─── VPC ─────────────────────────────────────────────────
    info "Criando VPC ($VPC_CIDR)..."

    VPC_ID=$(awslocal ec2 create-vpc \
        --cidr-block "$VPC_CIDR" \
        --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=vpc-portfolio}]' \
        --query 'Vpc.VpcId' \
        --output text)

    success "VPC criada: $VPC_ID"

    # ─── SUBNETS ─────────────────────────────────────────────
    info "Criando subnet publica ($SUBNET_PUB_CIDR)..."

    SUBNET_PUB=$(awslocal ec2 create-subnet \
        --vpc-id "$VPC_ID" \
        --cidr-block "$SUBNET_PUB_CIDR" \
        --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=subnet-publica}]' \
        --query 'Subnet.SubnetId' \
        --output text)

    success "Subnet publica criada: $SUBNET_PUB"

    info "Criando subnet privada ($SUBNET_PRIV_CIDR)..."

    SUBNET_PRIV=$(awslocal ec2 create-subnet \
        --vpc-id "$VPC_ID" \
        --cidr-block "$SUBNET_PRIV_CIDR" \
        --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=subnet-privada}]' \
        --query 'Subnet.SubnetId' \
        --output text)

    success "Subnet privada criada: $SUBNET_PRIV"

    # Habilita IP publico automatico na subnet publica
    awslocal ec2 modify-subnet-attribute \
        --subnet-id "$SUBNET_PUB" \
        --map-public-ip-on-launch

    success "IP publico automatico habilitado na subnet publica."

    # ─── INTERNET GATEWAY ────────────────────────────────────
    info "Criando Internet Gateway..."

    IGW_ID=$(awslocal ec2 create-internet-gateway \
        --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=igw-portfolio}]' \
        --query 'InternetGateway.InternetGatewayId' \
        --output text)

    success "Internet Gateway criado: $IGW_ID"

    info "Anexando IGW à VPC..."

    awslocal ec2 attach-internet-gateway \
        --internet-gateway-id "$IGW_ID" \
        --vpc-id "$VPC_ID"

    success "IGW anexado à VPC."

    # ─── ROUTE TABLE ─────────────────────────────────────────
    info "Criando route table publica..."

    RTB_ID=$(awslocal ec2 create-route-table \
        --vpc-id "$VPC_ID" \
        --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=rtb-publica}]' \
        --query 'RouteTable.RouteTableId' \
        --output text)

    success "Route table criada: $RTB_ID"

    info "Adicionando rota para internet (0.0.0.0/0 → IGW)..."

    awslocal ec2 create-route \
        --route-table-id "$RTB_ID" \
        --destination-cidr-block 0.0.0.0/0 \
        --gateway-id "$IGW_ID" > /dev/null

    success "Rota para internet criada."

    info "Associando route table à subnet publica..."

    awslocal ec2 associate-route-table \
        --route-table-id "$RTB_ID" \
        --subnet-id "$SUBNET_PUB" > /dev/null

    success "Route table associada à subnet publica."

    # ─── RESUMO ──────────────────────────────────────────────
    echo ""
    echo "================================================"
    echo "  RESUMO DOS RECURSOS CRIADOS"
    echo "================================================"
    echo ""
    echo -e "  ${BLUE}VPC:${NC}             $VPC_ID  ($VPC_CIDR)"
    echo -e "  ${BLUE}Subnet publica:${NC}  $SUBNET_PUB  ($SUBNET_PUB_CIDR)"
    echo -e "  ${BLUE}Subnet privada:${NC}  $SUBNET_PRIV  ($SUBNET_PRIV_CIDR)"
    echo -e "  ${BLUE}Internet Gateway:${NC} $IGW_ID"
    echo -e "  ${BLUE}Route Table:${NC}     $RTB_ID"
    echo ""
    success "Infraestrutura de rede criada com sucesso!"
    echo ""
}

destruir_vpc() {
    verificar_localstack

    echo ""
    warning "Isso vai destruir todos os recursos de rede criados por este script."
    read -p "Tem certeza? (s/N): " CONFIRMA

    if [[ "$CONFIRMA" != "s" && "$CONFIRMA" != "S" ]]; then
        info "Operacao cancelada."
        exit 0
    fi

    # Busca recursos pelo nome da tag
    VPC_ID=$(awslocal ec2 describe-vpcs \
        --filters 'Name=tag:Name,Values=vpc-portfolio' \
        --query 'Vpcs[0].VpcId' --output text 2>/dev/null || true)

    if [[ -z "$VPC_ID" || "$VPC_ID" == "None" ]]; then
        warning "Nenhuma VPC com tag 'vpc-portfolio' encontrada."
        exit 0
    fi

    info "Removendo recursos da VPC $VPC_ID..."

    # Desanexa e deleta IGW
    IGW_ID=$(awslocal ec2 describe-internet-gateways \
        --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
        --query 'InternetGateways[0].InternetGatewayId' --output text 2>/dev/null || true)

    if [[ -n "$IGW_ID" && "$IGW_ID" != "None" ]]; then
        awslocal ec2 detach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID"
        awslocal ec2 delete-internet-gateway --internet-gateway-id "$IGW_ID"
        success "IGW removido: $IGW_ID"
    fi

    # Deleta subnets
    SUBNETS=$(awslocal ec2 describe-subnets \
        --filters "Name=vpc-id,Values=$VPC_ID" \
        --query 'Subnets[*].SubnetId' --output text 2>/dev/null || true)

    for SUBNET in $SUBNETS; do
        awslocal ec2 delete-subnet --subnet-id "$SUBNET"
        success "Subnet removida: $SUBNET"
    done

    # Deleta route tables não-default
    RTBS=$(awslocal ec2 describe-route-tables \
        --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=rtb-publica" \
        --query 'RouteTables[*].RouteTableId' --output text 2>/dev/null || true)

    for RTB in $RTBS; do
        awslocal ec2 delete-route-table --route-table-id "$RTB"
        success "Route table removida: $RTB"
    done

    # Deleta VPC
    awslocal ec2 delete-vpc --vpc-id "$VPC_ID"
    success "VPC removida: $VPC_ID"

    echo ""
    success "Todos os recursos removidos com sucesso!"
    echo ""
}

# ─── PONTO DE ENTRADA ────────────────────────────────────────
if [[ $# -eq 0 ]]; then
    criar_vpc
    exit 0
fi

case "$1" in
    -d) destruir_vpc ;;
    -h) mostrar_ajuda ;;
    *)  error "Opcao invalida: $1. Use -h para ver as opcoes." ;;
esac
