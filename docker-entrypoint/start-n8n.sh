#!/bin/sh
set -e

# Use Render's $PORT if provided, otherwise default to 5678
: "${PORT:=5678}"
export PORT

# Ensure n8n picks up the port and binds to 0.0.0.0
export N8N_PORT="$PORT"
export N8N_HOST="0.0.0.0"

# If you want https, N8N_PROTOCOL/N8N_SSL_KEY/N8N_SSL_CERT are already set in the Dockerfile

# Exec n8n so signals are forwarded correctly
exec n8n start --port "$PORT"
