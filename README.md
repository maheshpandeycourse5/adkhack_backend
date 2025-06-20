# AdHack Backend

FastAPI backend for the AdHack campaign management system.

## Setup Instructions

### 1. Prerequisites

#### Install PostgreSQL

Make sure you have PostgreSQL installed on your system.

**MacOS (using Homebrew):**

```bash
# Install PostgreSQL
brew install postgresql@14

# Start PostgreSQL Service
brew services start postgresql@14
```

**Ubuntu/Debian:**

```bash
# Update package lists
sudo apt update

# Install PostgreSQL
sudo apt install postgresql postgresql-contrib

# Start PostgreSQL Service
sudo systemctl enable postgresql
sudo systemctl start postgresql
```

**Windows:**

- Download and install from [PostgreSQL official website](https://www.postgresql.org/download/windows/)

#### Install libpq (Required for psycopg2-binary)

**MacOS:**

```bash
brew install libpq
```

**Ubuntu/Debian:**

```bash
sudo apt install libpq-dev
```

**Windows:**

- This is included with PostgreSQL installation

### 2. Automated Setup (Recommended)

We've provided a setup script that automates the installation process:

```bash
# Make the script executable
chmod +x setup_env.sh

# Run the setup script
./setup_env.sh
```

This script will:

- Check for required dependencies
- Create a Python virtual environment
- Install all required packages
- Create the PostgreSQL database
- Configure the database connection

### 3. Manual Setup (Alternative)

If you prefer manual setup, follow these steps:

#### Create a Virtual Environment

```bash
# Create a virtual environment
python3 -m venv venv

# Activate the virtual environment
# On Mac/Linux:
source venv/bin/activate

# On Windows:
# venv\Scripts\activate
```

#### Create a PostgreSQL Database

```bash
# Log in to PostgreSQL
psql -U postgres

# Create the database
CREATE DATABASE adhack_db;

# Exit PostgreSQL
\q

# Import the database schema
psql -U postgres -d adhack_db -f create_tables.sql
```

### 4. Install Dependencies

**MacOS (with M1/M2/M3 chip):**

```bash
# Set environment variables for libpq
export LDFLAGS="-L/opt/homebrew/opt/libpq/lib"
export CPPFLAGS="-I/opt/homebrew/opt/libpq/include"

# Install dependencies
pip install -r requirements.txt
```

**Linux/Windows/Intel Mac:**

```bash
pip install -r requirements.txt
```

If you encounter issues on any platform with `psycopg2-binary`, try installing it separately:

```bash
pip install psycopg2-binary
```

### 5. Configure Database Connection

Edit `app/database/database.py` to update your PostgreSQL connection settings:

```python
DATABASE_URL = "postgresql://username:password@localhost/adhack_db"
```

### 6. Run the Application

```bash
# Make sure your virtual environment is activated
uvicorn app.main:app --reload
```

The API will be available at http://localhost:8000

## Troubleshooting

### Issues with psycopg2-binary Installation

If you encounter issues installing `psycopg2-binary`, especially on Python 3.13+, try the following:

1. Ensure PostgreSQL development libraries are installed:

   ```bash
   # On MacOS
   brew install libpq

   # On Ubuntu/Debian
   sudo apt install libpq-dev postgresql-dev

   # On RHEL/CentOS/Fedora
   sudo dnf install postgresql-devel
   ```

2. Set environment variables before installing:

   ```bash
   # MacOS
   export LDFLAGS="-L/opt/homebrew/opt/libpq/lib"
   export CPPFLAGS="-I/opt/homebrew/opt/libpq/include"

   # Linux (might vary depending on installation)
   export LDFLAGS="-L/usr/local/lib"
   export CPPFLAGS="-I/usr/local/include"
   ```

3. Try installing psycopg2 from source:
   ```bash
   pip install psycopg2 --no-binary :all:
   ```

### Database Connection Issues

1. Verify PostgreSQL Service is Running:

   ```bash
   # On MacOS/Linux
   ps aux | grep postgres

   # On Windows (in PowerShell)
   Get-Service postgresql*
   ```

2. Check Connection String Format:

   - Correct format: `postgresql://username:password@host:port/database_name`
   - Default port is usually 5432

3. Test Connection with psql:
   ```bash
   psql -U username -h localhost -d database_name
   ```

## API Documentation

Once the server is running, access the interactive API documentation at:

- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## API Endpoints

### Campaign Management

- `POST /campaigns/`: Upload a new campaign with file upload or URL
- `GET /campaigns/`: List all campaigns
- `GET /campaigns/{campaign_id}`: Get a specific campaign
- `PUT /campaigns/{campaign_id}`: Update a campaign
- `DELETE /campaigns/{campaign_id}`: Delete a campaign
