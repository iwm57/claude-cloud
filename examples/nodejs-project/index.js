// Simple Express.js server example
// Run with: npm start

const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Routes
app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Cloud Development Environment!',
    timestamp: new Date().toISOString(),
    nodeVersion: process.version,
    platform: process.platform,
    architecture: process.arch
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', uptime: process.uptime() });
});

app.get('/info', (req, res) => {
  res.json({
    environment: 'cloud-dev',
    runtime: 'Node.js',
    version: process.version,
    memory: process.memoryUsage(),
    cpuUsage: process.cpuUsage()
  });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Access it at: http://localhost:${PORT}`);
  console.log('Try these endpoints:');
  console.log(`  GET  /          - Welcome message`);
  console.log(`  GET  /health    - Health check`);
  console.log(`  GET  /info      - System information`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully...');
  process.exit(0);
});
