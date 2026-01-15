#!/usr/bin/env python3
"""
Simple Flask server example
Run with: python app.py
Or with gunicorn: gunicorn -w 2 -b 0.0.0.0:5000 app:app
"""

from flask import Flask, jsonify
import platform
import os
from datetime import datetime

app = Flask(__name__)

# Routes
@app.route('/')
def home():
    """Welcome endpoint"""
    return jsonify({
        'message': 'Hello from Cloud Development Environment!',
        'timestamp': datetime.now().isoformat(),
        'python_version': platform.python_version(),
        'platform': platform.system(),
        'architecture': platform.machine()
    })

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'python-example'
    })

@app.route('/info')
def info():
    """System information endpoint"""
    return jsonify({
        'environment': 'cloud-dev',
        'runtime': 'Python',
        'version': platform.python_version(),
        'platform': platform.platform(),
        'processor': platform.processor(),
        'hostname': platform.node()
    })

@app.route('/api/env')
def env_info():
    """Environment variables (safe ones only)"""
    safe_envs = {k: v for k, v in os.environ.items()
                 if not any(sensitive in k.upper()
                           for sensitive in ['PASSWORD', 'KEY', 'SECRET', 'TOKEN'])}
    return jsonify({
        'environment_variables': len(safe_envs),
        'keys': list(safe_envs.keys())[:10]  # First 10 keys
    })

if __name__ == '__main__':
    PORT = int(os.environ.get('PORT', 5000))
    print(f"Starting Flask server on port {PORT}...")
    print(f"Access it at: http://localhost:{PORT}")
    print("Try these endpoints:")
    print("  GET  /          - Welcome message")
    print("  GET  /health    - Health check")
    print("  GET  /info      - System information")
    print("  GET  /api/env   - Environment info")
    app.run(host='0.0.0.0', port=PORT, debug=False)
