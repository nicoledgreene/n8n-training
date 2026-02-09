FROM bitovi/n8n-community-nodes:latest

USER root
RUN apk update && apk add --no-cache bash openssl

# Put custom node where n8n will load it from
RUN mkdir -p /home/node/custom-nodes/nodes
COPY n8n-custom/custom/nodes/GitHubActionError.node.js /home/node/custom-nodes/nodes/GitHubActionError.node.js

# Fail build if missing
RUN test -f /home/node/custom-nodes/nodes/GitHubActionError.node.js

# Fail build if node file can't be required
RUN node -e "require('/home/node/custom-nodes/nodes/GitHubActionError.node.js'); console.log('Custom node file loads');"

# Tell n8n to load custom nodes from this folder
ENV N8N_CUSTOM_EXTENSIONS=/home/node/custom-nodes
ENV N8N_COMMUNITY_PACKAGES_ENABLED=true
ENV N8N_LOG_LEVEL=debug

# Render-friendly networking
ENV N8N_PROTOCOL=http
ENV N8N_LISTEN_ADDRESS=0.0.0.0
ENV N8N_PORT=5678
EXPOSE 5678

RUN chown -R node:node /home/node/custom-nodes

USER node

# Explicitly start n8n
CMD ["n8n", "start"]
