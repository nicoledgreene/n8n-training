# -------- Stage 1: build your custom node --------
FROM node:20-alpine AS customnodebuilder

WORKDIR /build/n8n-custom
COPY n8n-custom/ ./

RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi
RUN npm pack

# -------- Stage 2: your current n8n image --------
FROM bitovi/n8n-community-nodes:latest

USER root

# Install bash and OpenSSL for certificate generation
RUN apk update && apk add --no-cache bash openssl

# --- Install your custom node globally into the n8n runtime ---
COPY --from=customnodebuilder /build/n8n-custom/*.tgz /tmp/custom-node.tgz
RUN npm install -g /tmp/custom-node.tgz && rm -f /tmp/custom-node.tgz

RUN npm list -g --depth=0 | grep -i n8n
RUN node -e "console.log('custom node installed:', !!require.resolve('n8n-nodes-github-action-error/package.json'))"
RUN node -e "console.log(require('n8n-nodes-github-action-error/package.json'))"

# Make sure n8n will load community packages
ENV N8N_COMMUNITY_PACKAGES_ENABLED=true

# Set proper ownership for npm global directories
RUN chown -R node:node /usr/local/lib /usr/local/bin

USER node

# Create directory for certificates
RUN mkdir -p /home/node/certificates
WORKDIR /home/node/certificates

# Generate self-signed certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout n8n-key.pem -out n8n-cert.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Set proper permissions for the private key
RUN chmod 600 /home/node/certificates/n8n-key.pem

# Default protocol (Render env vars can override this at runtime)
ENV N8N_PROTOCOL=http

EXPOSE 5678

COPY --chown=node:node docker-entrypoint/start-n8n.sh /home/node/start-n8n.sh
RUN chmod +x /home/node/start-n8n.sh

ENTRYPOINT ["/home/node/start-n8n.sh"]
