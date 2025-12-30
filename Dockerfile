FROM bitovi/n8n-community-nodes:latest

USER root

# Install bash and OpenSSL for certificate generation
RUN apk update && apk add --no-cache bash openssl

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

# Set environment variables for SSL configuration
ENV N8N_PROTOCOL=https
ENV N8N_SSL_KEY=/home/node/certificates/n8n-key.pem
ENV N8N_SSL_CERT=/home/node/certificates/n8n-cert.pem

# Expose the default n8n HTTP port so Render's port scanner can see it
EXPOSE 5678

# Copy startup script that honors the $PORT Render provides and starts n8n
COPY --chown=node:node docker-entrypoint/start-n8n.sh /home/node/start-n8n.sh
RUN chmod +x /home/node/start-n8n.sh

# Use the entrypoint script which will set PORT/N8N_PORT/N8N_HOST and exec n8n
ENTRYPOINT ["/home/node/start-n8n.sh"]

# You can set a custom entrypoint here to check the certificate files before starting n8n
# or use the default one provided by the base image
