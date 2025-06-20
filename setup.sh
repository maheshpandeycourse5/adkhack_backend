#!/bin/bash

# Create database
echo "Creating PostgreSQL database..."
createdb -U postgres adhack_db || echo "Database may already exist, continuing..."

# Run the SQL script
echo "Creating tables..."
psql -U postgres -d adhack_db -f create_tables.sql

# Install dependencies
echo "Installing Python dependencies..."
pip install -r requirements.txt

# Create upload directory
mkdir -p uploads

echo "Setup complete! Run 'uvicorn run:app --reload' to start the server."
