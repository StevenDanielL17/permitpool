#!/bin/bash

# PermitPool Development Startup Script
# Optimized for multi-app development without system crashes

set -e

PROJECT_DIR="/home/stevendaniell/BackUp/Dan/dansprojects/Eth-Online"
cd "$PROJECT_DIR"

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 PermitPool Development Environment${NC}"
echo -e "${BLUE}=====================================${NC}\n"

# Check if node_modules exist
if [ ! -d "admin-portal/node_modules" ] || [ ! -d "trader-app/node_modules" ]; then
    echo -e "${BLUE}📦 Installing dependencies...${NC}"
    npm install --workspaces
    echo -e "${GREEN}✅ Dependencies installed${NC}\n"
fi

# Export memory optimizations
export NODE_OPTIONS="--max-old-space-size=4096 --max-semi-space-size=512"
export NODE_ENV="development"
export NEXT_TELEMETRY_DISABLED=1
export DISABLE_TURBOPACK=1

echo -e "${GREEN}✅ Environment optimized${NC}"
echo -e "${GREEN}   - Node max old space: 4096MB${NC}"
echo -e "${GREEN}   - Turbopack disabled (SWC mode)${NC}"
echo -e "${GREEN}   - Telemetry disabled${NC}\n"

# Check which mode to run
if [ "$1" == "admin" ]; then
    echo -e "${BLUE}Starting Admin Portal...${NC}"
    cd admin-portal
    npm run dev
elif [ "$1" == "trader" ]; then
    echo -e "${BLUE}Starting Trader App...${NC}"
    cd trader-app
    npm run dev
elif [ "$1" == "both" ]; then
    echo -e "${BLUE}⚠️  WARNING: Running both apps requires 2 terminals!${NC}\n"
    echo -e "${BLUE}Start in separate terminals:${NC}"
    echo -e "   Terminal 1: npm run dev:admin"
    echo -e "   Terminal 2: npm run dev:trader\n"
    exit 0
else
    echo -e "${BLUE}Usage: ./start.sh [admin|trader|both]${NC}\n"
    echo -e "Examples:"
    echo -e "   ./start.sh admin      # Start admin portal only"
    echo -e "   ./start.sh trader     # Start trader app only"
    echo -e "   ./start.sh both       # Show instructions for running both\n"
    exit 1
fi
