# BEACON Token Service - Cloud Version

Production-ready version of the BEACON token service for 24/7 deployment.

## Differences from Laptop Version

| Feature | Laptop Version | Cloud Version |
|---------|---------------|---------------|
| Use Case | Development/POC | Production/Demo |
| Availability | Only when laptop is on | 24/7 |
| Health Checks | Basic | Full (health, ready, metrics) |
| CORS | Open | Configurable origins |
| Logging | Console only | Production-ready |
| Monitoring | None | Health/metrics endpoints |
| Deployment | npm start | Docker, Azure, AWS, Heroku |

## Quick Start

### Local Testing

```bash
# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env with your Azure credentials

# Start service
npm start

# Test
curl http://localhost:3000/health
```

### Docker Deployment

```bash
# Build image
docker build -t beacon-token-service .

# Run container
docker run -d \
  -p 3000:3000 \
  -e TENANT_ID=your-tenant-id \
  -e CLIENT_ID=your-client-id \
  -e CLIENT_SECRET=your-secret \
  --name beacon-token-service \
  beacon-token-service

# Check logs
docker logs -f beacon-token-service
```

## Cloud Deployment Options

### Azure App Service (Recommended for Azure users)

1. Create App Service:
```bash
az webapp create \
  --resource-group beacon-rg \
  --plan beacon-plan \
  --name beacon-token-service \
  --runtime "NODE:20-lts"
```

2. Configure environment variables:
```bash
az webapp config appsettings set \
  --resource-group beacon-rg \
  --name beacon-token-service \
  --settings \
    TENANT_ID=xxx \
    CLIENT_ID=xxx \
    CLIENT_SECRET=xxx \
    NODE_ENV=production
```

3. Deploy code:
```bash
az webapp up \
  --resource-group beacon-rg \
  --name beacon-token-service
```

Your service will be available at: `https://beacon-token-service.azurewebsites.net`

### AWS Elastic Beanstalk

1. Install EB CLI: `pip install awsebcli`

2. Initialize:
```bash
eb init -p node.js-20 beacon-token-service
```

3. Create environment:
```bash
eb create beacon-production \
  --envvars TENANT_ID=xxx,CLIENT_ID=xxx,CLIENT_SECRET=xxx
```

4. Deploy:
```bash
eb deploy
```

### Heroku

1. Install Heroku CLI: https://devcenter.heroku.com/articles/heroku-cli

2. Create app:
```bash
heroku create beacon-token-service
```

3. Set environment variables:
```bash
heroku config:set TENANT_ID=xxx
heroku config:set CLIENT_ID=xxx
heroku config:set CLIENT_SECRET=xxx
heroku config:set NODE_ENV=production
```

4. Deploy:
```bash
git push heroku main
```

## Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Service information |
| `/health` | GET | Health check (for load balancers) |
| `/ready` | GET | Readiness check (validates Azure connection) |
| `/metrics` | GET | Service metrics (memory, uptime) |
| `/api/embed-token` | POST | Generate Power BI embed token |

## Security Considerations

### Production Checklist

- [ ] Use HTTPS (required for Power BI)
- [ ] Restrict CORS origins to your display devices
- [ ] Store secrets in vault (Azure Key Vault, AWS Secrets Manager)
- [ ] Enable logging and monitoring
- [ ] Set up alerts for service failures
- [ ] Rotate CLIENT_SECRET every 12 months
- [ ] Use managed identity where possible (Azure)
- [ ] Implement rate limiting for public endpoints
- [ ] Keep dependencies updated (npm audit)

### CORS Configuration

For production, restrict origins in .env:
```bash
ALLOWED_ORIGINS=https://display1.company.com,https://display2.company.com
```

For development/testing only:
```bash
ALLOWED_ORIGINS=*
```

## Monitoring

### Health Check
```bash
curl https://your-service.com/health
```

Response:
```json
{
  "status": "healthy",
  "timestamp": "2025-11-11T20:00:00.000Z",
  "uptime": 3600,
  "version": "1.0.0",
  "environment": "production"
}
```

### Readiness Check
```bash
curl https://your-service.com/ready
```

Response when ready:
```json
{
  "ready": true
}
```

### Metrics
```bash
curl https://your-service.com/metrics
```

Response:
```json
{
  "uptime": 3600,
  "memory": {
    "used": 50,
    "total": 128
  },
  "timestamp": "2025-11-11T20:00:00.000Z"
}
```

## Troubleshooting

### Token generation fails

**Error**: "Cannot acquire Azure AD token"

**Solutions**:
1. Verify environment variables are set correctly
2. Check CLIENT_SECRET hasn't expired (12-month validity)
3. Verify service principal exists in Azure AD
4. Check service principal is added to Power BI workspace

### CORS errors in browser

**Error**: "blocked by CORS policy"

**Solutions**:
1. Set ALLOWED_ORIGINS to include your display client origin
2. Ensure HTTPS is used in production
3. Check that display client URL matches exactly (including protocol)

### High memory usage

**Cause**: Memory leak or too many concurrent requests

**Solutions**:
1. Monitor `/metrics` endpoint
2. Restart service if memory > 80%
3. Scale horizontally (add more instances)
4. Implement request caching

## Cost Estimates

### Azure App Service
- Free tier: $0/month (good for POC, limited availability)
- Basic B1: ~$13/month (99.95% SLA, recommended for production)
- Standard S1: ~$70/month (auto-scaling, staging slots)

### AWS Elastic Beanstalk
- t3.micro: ~$8/month (good for small deployments)
- t3.small: ~$17/month (recommended for production)

### Heroku
- Free tier: $0/month (sleeps after 30 min inactivity)
- Hobby: $7/month (always on, no SSL)
- Standard: $25/month (SSL, metrics, recommended)

### Azure Container Instances
- 1 vCPU, 1GB RAM: ~$35/month (pay per second, highly available)

## Next Steps for Company Deployment

See `COMPANY-DEPLOYMENT.md` in the project root for:
- Corporate network integration
- Security review requirements
- IT infrastructure considerations
- Multi-device management
- Centralized logging and monitoring
