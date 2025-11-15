# BEACON Token Service - Dockerfile
# Build and run the token service in a container
# Suitable for Docker, Kubernetes, AWS ECS, Azure Container Instances, etc.

# Use official Node.js LTS image
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install production dependencies only
RUN npm ci --only=production

# Copy application code
COPY server.js ./

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# Expose port (configurable via PORT environment variable)
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start the service
CMD ["node", "server.js"]

# Build and run instructions:
#
# Build:
#   docker build -t beacon-token-service:latest .
#
# Run locally:
#   docker run -d \
#     -p 3000:3000 \
#     -e TENANT_ID=your-tenant-id \
#     -e CLIENT_ID=your-client-id \
#     -e CLIENT_SECRET=your-secret \
#     -e NODE_ENV=production \
#     --name beacon-token-service \
#     beacon-token-service:latest
#
# View logs:
#   docker logs -f beacon-token-service
#
# Stop:
#   docker stop beacon-token-service
#
# Deploy to Azure Container Instances:
#   az container create \
#     --resource-group beacon-rg \
#     --name beacon-token-service \
#     --image beacon-token-service:latest \
#     --dns-name-label beacon-token \
#     --ports 3000 \
#     --environment-variables \
#       TENANT_ID=xxx \
#       CLIENT_ID=xxx \
#     --secure-environment-variables \
#       CLIENT_SECRET=xxx
