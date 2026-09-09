# perplexity-mcp-server

Hosted [Perplexity MCP server](https://www.npmjs.com/package/@perplexity-ai/mcp-server)
for ASIW. This repo is **not** a custom server — it is a thin Docker wrapper
that installs Perplexity's official npm package and runs its HTTP transport.

- **Live URL:** `https://perplexity-mcp-server-production-dac3.up.railway.app/mcp`
- **Health check:** `https://perplexity-mcp-server-production-dac3.up.railway.app/health`
- **Deploys:** push to `main` → Railway builds and deploys automatically
  (Railway project `pure-art`, service `perplexity-mcp-server`).

## Tools exposed

`perplexity_ask`, `perplexity_research`, `perplexity_reason`, `perplexity_search`

## Required Railway variables

| Variable | Value | Why |
| --- | --- | --- |
| `PERPLEXITY_API_KEY` | *(secret)* | Perplexity API auth. |
| `ALLOWED_HOSTS` | `perplexity-mcp-server-production-dac3.up.railway.app` | **Required since 1.0.0.** The package added a Host header allowlist; without the Railway domain listed here every request is rejected with `421 Misdirected request`. Update this if the domain ever changes. |
| `ALLOWED_ORIGINS` | `*` | Cross-origin browser clients. Server-to-server callers send no `Origin` and are allowed regardless. |

`PORT` and `BIND_ADDRESS` are set in the Dockerfile. `BIND_ADDRESS=0.0.0.0` is
required because the package defaults to loopback-only since 1.0.0.

## Upgrading

The version is pinned in the Dockerfile **on purpose**. An unpinned
`npm install` is how this service silently ran 0.9.0 from April 2026 to
September 2026 — that version crashed with "Already connected to a transport"
on any concurrent request. To upgrade, bump the version in the Dockerfile,
push, then re-run the verification below.

## Verifying a deploy

```sh
BASE=https://perplexity-mcp-server-production-dac3.up.railway.app

# 1. health
curl -s $BASE/health

# 2. handshake — check "version" in the response matches the pinned version
curl -s $BASE/mcp -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"verify","version":"1.0"}}}'

# 3. concurrency — the regression test. Ten at once must all return 4 tools.
for i in $(seq 1 10); do
  curl -s $BASE/mcp -H 'Content-Type: application/json' \
    -H 'Accept: application/json, text/event-stream' \
    -d '{"jsonrpc":"2.0","id":'$i',"method":"tools/list","params":{}}' \
    | grep -c perplexity_ask &
done; wait
```
