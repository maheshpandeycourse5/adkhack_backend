#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========== AdHack Backend Setup ==========${NC}"

# Check if Python 3 is installed
if command -v python3 &>/dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo -e "${GREEN}✓ Python is installed: ${PYTHON_VERSION}${NC}"
else
    echo -e "${RED}✗ Python 3 is not installed. Please install Python 3 and try again.${NC}"
    exit 1
fi

# Check if PostgreSQL is installed
if command -v psql &>/dev/null; then
    PSQL_VERSION=$(psql --version)
    echo -e "${GREEN}✓ PostgreSQL is installed: ${PSQL_VERSION}${NC}"
else
    echo -e "${RED}✗ PostgreSQL is not installed. Please install PostgreSQL and try again.${NC}"
    echo -e "${YELLOW}  MacOS: brew install postgresql@14${NC}"
    echo -e "${YELLOW}  Ubuntu/Debian: sudo apt install postgresql postgresql-contrib${NC}"
    echo -e "${YELLOW}  Windows: Download from https://www.postgresql.org/download/windows/${NC}"
    exit 1
fi

# Check if libpq is installed (MacOS specific)
if [[ $(uname) == "Darwin" ]]; then
    if brew list libpq &>/dev/null; then
        echo -e "${GREEN}✓ libpq is installed${NC}"
        # Export environment variables for psycopg2 compilation
        export LDFLAGS="-L/opt/homebrew/opt/libpq/lib"
        export CPPFLAGS="-I/opt/homebrew/opt/libpq/include"
        echo -e "${YELLOW}Environment variables set:${NC}"
        echo -e "${YELLOW}  LDFLAGS=${LDFLAGS}${NC}"
        echo -e "${YELLOW}  CPPFLAGS=${CPPFLAGS}${NC}"
    else
        echo -e "${YELLOW}! libpq is not installed. Installing...${NC}"
        brew install libpq
        export LDFLAGS="-L/opt/homebrew/opt/libpq/lib"
        export CPPFLAGS="-I/opt/homebrew/opt/libpq/include"
    fi
fi

# Create virtual environment
echo -e "${YELLOW}Creating virtual environment...${NC}"
python3 -m venv venv
source venv/bin/activate
echo -e "${GREEN}✓ Virtual environment created and activated${NC}"

# Upgrade pip
echo -e "${YELLOW}Upgrading pip...${NC}"
pip install --upgrade pip
echo -e "${GREEN}✓ pip upgraded${NC}"

# Install requirements
echo -e "${YELLOW}Installing dependencies...${NC}"
pip install -r requirements.txt

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Dependencies installed successfully${NC}"
else
    echo -e "${RED}✗ Dependencies installation failed. Trying individual packages...${NC}"
    
    # Try installing packages individually
    echo -e "${YELLOW}Installing individual packages...${NC}"
    pip install fastapi uvicorn
    pip install sqlalchemy
    pip install python-multipart python-jose passlib uuid
    
    # Handle psycopg2-binary installation separately
    echo -e "${YELLOW}Installing psycopg2-binary...${NC}"
    pip install psycopg2-binary
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Failed to install psycopg2-binary. Trying alternative method...${NC}"
        if [[ $(uname) == "Darwin" ]]; then
            export LDFLAGS="-L/opt/homebrew/opt/libpq/lib"
            export CPPFLAGS="-I/opt/homebrew/opt/libpq/include"
        fi
        pip install psycopg2-binary
    fi
fi

# Prompt to create database
echo -e "${YELLOW}Do you want to create a new PostgreSQL database? [y/N]${NC}"
read -r CREATE_DB

if [[ $CREATE_DB =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Enter database name [adhack_db]:${NC}"
    read -r DB_NAME
    DB_NAME=${DB_NAME:-adhack_db}
    
    echo -e "${YELLOW}Enter PostgreSQL username [postgres]:${NC}"
    read -r DB_USER
    DB_USER=${DB_USER:-postgres}
    
    echo -e "${YELLOW}Creating database ${DB_NAME}...${NC}"
    createdb -U "$DB_USER" "$DB_NAME" || echo -e "${YELLOW}Database might already exist, proceeding...${NC}"
    
    echo -e "${YELLOW}Running database schema creation script...${NC}"
    psql -U "$DB_USER" -d "$DB_NAME" -f create_tables.sql
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Database and tables created successfully${NC}"
    else
        echo -e "${RED}✗ Database schema creation failed${NC}"
    fi
    
    # Update database connection string in database.py
    echo -e "${YELLOW}Setting up database connection string...${NC}"
    echo -e "${YELLOW}Enter PostgreSQL password for user ${DB_USER}:${NC}"
    read -r -s DB_PASSWORD
    
    # Safely replace DATABASE_URL
    sed -i.bak "s|DATABASE_URL = \".*\"|DATABASE_URL = \"postgresql://${DB_USER}:${DB_PASSWORD}@localhost/${DB_NAME}\"|" app/database/database.py
    rm -f app/database/database.py.bak
    echo -e "${GREEN}✓ Database connection string updated${NC}"
fi

echo -e "${GREEN}========== Setup Completed ==========${NC}"
echo -e "${YELLOW}To start the application:${NC}"
echo -e "${YELLOW}1. Activate the virtual environment (if not already active):${NC}"
echo -e "${YELLOW}   source venv/bin/activate${NC}"
echo -e "${YELLOW}2. Start the server:${NC}"
echo -e "${YELLOW}   uvicorn app.main:app --reload${NC}"
echo -e "${YELLOW}3. Access the API at http://localhost:8000${NC}"
echo -e "${YELLOW}4. Access the API documentation at http://localhost:8000/docs${NC}"
