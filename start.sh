#!/bin/sh
# The published package ships a prebuilt dist/ and installs no devDependencies,
# so the old `npm run build` step here could never have succeeded — it was
# silently swallowed by `2>/dev/null || true` on every boot. Dropped.
#
# exec node directly rather than going through `npm run start:http`, so the
# node process is PID 1 and receives SIGTERM from Railway on shutdown instead
# of npm swallowing it.
exec node /app/node_modules/@perplexity-ai/mcp-server/dist/http.js
