FROM bitovi/n8n-community-nodes:latest

USER root

RUN apk update && apk add --no-cache bash openssl

# Install your custom node package globally
COPY n8n-custom/ /tmp/n8n-custom/
RUN npm install -g /tmp/n8n-custom && rm -rf /tmp/n8n-custom
RUN find /usr/local/lib/node_modules/n8n-nodes-github-action-error -maxdepth 4 -type f
RUN node -e "require('/usr/local/lib/node_modules/n8n-nodes-github-action-error/custom/nodes/GitHubActionError.node.js'); console.log('node loads')"

ENV N8N_COMMUNITY_PACKAGES_ENABLED=true

RUN chown -R node:node /usr/local/lib /usr/local/bin

USER node

RUN mkdir -p /home/node/certificates
WORKDIR /home/node/certificates

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout n8n-key.pem -out n8n-cert.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

RUN chmod 600 /home/node/certificates/n8n-key.pem

ENV N8N_PROTOCOL=https
ENV N8N_SSL_KEY=/home/node/certificates/n8n-key.pem
ENV N8N_SSL_CERT=/home/node/certificates/n8n-cert.pem
