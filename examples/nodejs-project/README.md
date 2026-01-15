# Node.js Example Project

A simple Express.js server to demonstrate the cloud development environment.

## Setup

```bash
# In your container's /workspace directory:
cd /workspace

# Copy the example files
cp -r /path/to/examples/nodejs-project/* .

# Install dependencies
npm install
```

## Run

```bash
# Start the server
npm start
```

The server will start on port 3000.

## Test

```bash
# In another terminal (or using Claude CLI):
curl http://localhost:3000
curl http://localhost:3000/health
curl http://localhost:3000/info
```

## Using Claude CLI

```bash
# Ask Claude to help modify the app
claude "Add a new endpoint /api/users that returns a list of users"

# Or ask for debugging help
claude "Why is my server not responding on port 3000?"
```

## Files

- `package.json` - Project configuration and dependencies
- `index.js` - Main application file
- `README.md` - This file
