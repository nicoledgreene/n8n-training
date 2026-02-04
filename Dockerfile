# -------- Stage 1: pack your custom node package --------
FROM node:20-alpine AS customnodebuilder

WORKDIR /build/n8n-custom
COPY n8n-custom/ ./

RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi
RUN npm pack


# -------- Stage 2: n8n + install your custom package --------
FROM bitovi/n8n-community-nodes:latest

USER root

RUN apk update && apk add --no-cache bash openssl

# Install your custom node globally into the n8n runtime
COPY --from=customnodebuilder /build/n8n-custom/*.tgz /tmp/custom-node.tgz
RUN npm install -g /tmp/custom-node.tgz && rm -f /tmp/custom-node.tgz

# Make sure n8n will load community packages
ENV N8N_COMMUNITY_PACKAGES_ENABLED=true

# Optional debug (won't fail build)
RUN npm list -g --depth=0 | grep -i n8n || true
RUN node -e "try{require.resolve('n8n-custom/package.json'); console.log('FOUND n8n-custom');}catch(e){console.log('NOT FOUND n8n-custom:', e.message)}"
RUN node -e "try{console.log(require('n8n-custom/package.json'))}catch(e){console.log('cannot read package.json:', e.message)}"

# Ownership for npm global dirs (matches your prior setup)
RUN chown -R node:node /usr/local/lib /usr/local/bin

USER node

# Certificates (as you had before)
RUN mkdir -p /home/node/certificates
WORKDIR /home/node/certificates

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout n8n-key.pem -out n8n-cert.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

RUN chmod 600 /home/node/certificates/n8n-key.pem

# Render env vars can override this
ENV N8N_PROTOCOL=http

EXPOSE 5678

# Keep your start script!
COPY --chown=node:node docker-entrypoint/start-n8n.sh /home/node/start-n8n.sh
RUN chmod +x /home/node/start-n8n.sh

ENTRYPOINT ["/home/node/start-n8n.sh"]
