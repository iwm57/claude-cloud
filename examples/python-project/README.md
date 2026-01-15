# Python Example Project

A simple Flask web application to demonstrate the cloud development environment.

## Setup

```bash
# In your container's /workspace directory:
cd /workspace

# Copy the example files
cp -r /path/to/examples/python-project/* .

# Create virtual environment (recommended)
python3 -m venv venv
source venv/bin/activate  # Activate virtual environment

# Install dependencies
pip install -r requirements.txt
```

## Run

### Development Server

```bash
# Activate virtual environment first
source venv/bin/activate

# Run with Flask's built-in server
python app.py
```

### Production Server (with gunicorn)

```bash
# Activate virtual environment first
source venv/bin/activate

# Run with gunicorn (more robust)
gunicorn -w 2 -b 0.0.0.0:5000 app:app
```

The server will start on port 5000.

## Test

```bash
# In another terminal (or using Claude CLI):
curl http://localhost:5000
curl http://localhost:5000/health
curl http://localhost:5000/info
curl http://localhost:5000/api/env
```

## Using Claude CLI

```bash
# Ask Claude to help modify the app
claude "Add a new endpoint /api/users that returns a list of users"

# Or ask for debugging help
claude "How do I add authentication to my Flask app?"

# Or get help with dependencies
claude "Add requests library to requirements.txt and show me how to use it"
```

## Files

- `requirements.txt` - Python dependencies
- `app.py` - Main Flask application
- `README.md` - This file

## Virtual Environment

Always use a virtual environment for Python projects:

```bash
# Create
python3 -m venv venv

# Activate
source venv/bin/activate

# Deactivate when done
deactivate
```

This isolates your project dependencies from the system Python.
