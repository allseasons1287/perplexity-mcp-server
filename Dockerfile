FROM node:20-slim

WORKDIR /app

RUN npm init -y && npm install @perplexity-ai/mcp-server

COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

ENV PORT=8080
ENV BIND_ADDRESS=0.0.0.0
EXPOSE 8080

CMD ["/app/start.sh"]
