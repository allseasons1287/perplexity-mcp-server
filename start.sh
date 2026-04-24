#!/bin/sh
cd /app/node_modules/@perplexity-ai/mcp-server
npm run build 2>/dev/null || true
npm run start:http
