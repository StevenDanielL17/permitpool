#!/bin/bash

# PermitPool Build Optimization Script
# Builds apps with memory limits to prevent crashes

set -e

PROJECT_DIR="/home/stevendaniell/BackUp/Dan/dansprojects/Eth-Online"
cd "$PROJECT_DIR"

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔨 PermitPool Build Optimizer${NC}"
echo -e "${BLUE}==============================${NC}\n"

# Export memory optimizations
export NODE_OPTIONS="--max-old-space-size=4096 --max-semi-space-size=512"
export NODE_ENV="production"
export DISABLE_TURBOPACK=1

# Install dependencies if missing
if [ ! -d "admin-portal/node_modules" ] || [ ! -d "trader-app/node_modules" ]; then
    echo -e "${BLUE}📦 Installing dependencies...${NC}"
    npm install --workspaces
    echo -e "${GREEN}✅ Dependencies installed\n${NC}"
fi

# Build based on argument
if [ "$1" == "admin" ]; then
    echo -e "${BLUE}Building Admin Portal...${NC}"
    cd admin-portal
    npm run build
    echo -e "${GREEN}✅ Admin Portal built successfully${NC}"
    
elif [ "$1" == "trader" ]; then
    echo -e "${BLUE}Building Trader App...${NC}"
    cd trader-app
    npm run build
    echo -e "${GREEN}✅ Trader App built successfully${NC}"
    
elif [ "$1" == "all" ] || [ -z "$1" ]; then
    echo -e "${BLUE}Building Admin Portal...${NC}"
    cd admin-portal
    npm run build
    echo -e "${GREEN}✅ Admin Portal built\n${NC}"
    
    cd "$PROJECT_DIR"
    echo -e "${BLUE}Building Trader App...${NC}"
    cd trader-app
    npm run build
    echo -e "${GREEN}✅ Trader App built\n${NC}"
    
    cd "$PROJECT_DIR"
    echo -e "${GREEN}✅ All apps built successfully${NC}\n"
    echo -e "${GREEN}Ready for deployment:${NC}"
    echo -e "   Admin: .next in admin-portal/"
    echo -e "   Trader: .next in trader-app/"
    
else
    echo -e "${RED}Unknown build target: $1${NC}\n"
    echo -e "Usage: ./build.sh [admin|trader|all]"
    exit 1
fi
