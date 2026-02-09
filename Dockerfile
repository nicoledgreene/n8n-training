FROM bitovi/n8n-community-nodes:latest

USER root
RUN apk update && apk add --no-cache bash openssl

# Put your custom node where n8n will load it from
RUN mkdir -p /home/node/custom-nodes/nodes
COPY n8n-custom/custom/nodes/ /home/node/custom-nodes/nodes/

# Tell n8n to load nodes from this folder
ENV N8N_CUSTOM_EXTENSIONS=/home/node/custom-nodes
ENV N8N_COMMUNITY_PACKAGES_ENABLED=true

# (Render port binding safety)
ENV N8N_PROTOCOL=http
ENV N8N_LISTEN_ADDRESS=0.0.0.0
EXPOSE 5678

RUN chown -R node:node /home/node/custom-nodes

USER node
