FROM node:20-slim

WORKDIR /app

# Pin the upstream version deliberately.
#
# An unpinned `npm install` is how this service silently drifted: the
# 2026-04-24 build picked up 0.9.0, whose HTTP mode created ONE MCP server at
# module scope and reconnected it to a fresh transport on every request:
#
#     const mcpServer = createPerplexityServer();   // once, at module scope
#     app.all("/mcp", async (req, res) => {
#       const transport = new StreamableHTTPServerTransport({...});
#       await mcpServer.connect(transport);         // throws on the 2nd caller
#
# A Protocol instance supports exactly one transport, so any second or
# overlapping request threw "Already connected to a transport" (observed in
# Railway logs 2026-09-09 22:07 UTC). Upstream fixed this in 1.x by building a
# fresh server + transport pair inside the request handler.
#
# Bump this version on purpose, never implicitly.
RUN npm init -y && npm install @perplexity-ai/mcp-server@1.2.1

COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

ENV PORT=8080
# 1.2.1 changed the default BIND_ADDRESS to 127.0.0.1 (loopback only).
# Railway routes to the container from outside, so bind all interfaces.
ENV BIND_ADDRESS=0.0.0.0
EXPOSE 8080

CMD ["/app/start.sh"]
