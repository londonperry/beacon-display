// BEACON Token Service - Cloud Version
// Generates Power BI embed tokens for display authentication
// For production use - deploy to Azure App Service, AWS, or similar
// Differences from laptop version:
//   - Health checks for monitoring
//   - Better logging for production
//   - CORS configured for specific origins
//   - Ready for HTTPS deployment

require('dotenv').config();
const express = require('express');
const msal = require('@azure/msal-node');
const cors = require('cors');

const app = express();

// Security headers middleware (MUST be first, before other middleware)
app.use((req, res, next) => {
    // Prevent MIME type sniffing
    res.setHeader('X-Content-Type-Options', 'nosniff');

    // Prevent clickjacking
    res.setHeader('X-Frame-Options', 'DENY');

    // Enable XSS filter (legacy browsers)
    res.setHeader('X-XSS-Protection', '1; mode=block');

    // Content Security Policy for API responses
    // Strict policy: don't load any resources, prevent framing
    res.setHeader('Content-Security-Policy', "default-src 'none'; frame-ancestors 'none'");

    // Strict-Transport-Security (HSTS) - enforce HTTPS
    // Only set in production with HTTPS
    if (process.env.NODE_ENV === 'production') {
        // max-age=31536000 = 1 year
        // includeSubDomains = apply to all subdomains
        // preload = allow browser preload list inclusion
        res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains; preload');
    }

    // Remove X-Powered-By header (don't advertise Express)
    res.removeHeader('X-Powered-By');

    next();
});

// Disable X-Powered-By header globally
app.disable('x-powered-by');

// CORS configuration - restrict to your display clients in production
const corsOptions = {
    origin: process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : '*',
    methods: ['GET', 'POST'],
    credentials: true
};

// Middleware
app.use(cors(corsOptions));
app.use(express.json());

// Request logging middleware
app.use((req, res, next) => {
    const timestamp = new Date().toISOString();
    console.log(`[${timestamp}] ${req.method} ${req.path} - IP: ${req.ip}`);
    next();
});

// MSAL configuration for Azure AD authentication
const msalConfig = {
    auth: {
        clientId: process.env.CLIENT_ID,
        authority: `https://login.microsoftonline.com/${process.env.TENANT_ID}`,
        clientSecret: process.env.CLIENT_SECRET,
    }
};

const cca = new msal.ConfidentialClientApplication(msalConfig);

// Get Azure AD access token
async function getAccessToken() {
    const tokenRequest = {
        scopes: ['https://analysis.windows.net/powerbi/api/.default']
    };

    try {
        const response = await cca.acquireTokenByClientCredential(tokenRequest);
        console.log('✓ Azure AD access token acquired');
        return response.accessToken;
    } catch (error) {
        console.error('✗ Error acquiring access token:', error.message);
        throw error;
    }
}

// Generate Power BI embed token
async function getEmbedToken(groupId, reportId, accessToken) {
    const embedUrl = `https://api.powerbi.com/v1.0/myorg/groups/${groupId}/reports/${reportId}`;

    try {
        const response = await fetch(`${embedUrl}/GenerateToken`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${accessToken}`
            },
            body: JSON.stringify({
                accessLevel: 'View'
            })
        });

        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`Power BI API error: ${response.status} - ${errorText}`);
        }

        const data = await response.json();
        console.log(`✓ Embed token generated for report ${reportId}`);

        return {
            token: data.token,
            embedUrl: embedUrl,
            expiration: data.expiration
        };
    } catch (error) {
        console.error('✗ Error generating embed token:', error.message);
        throw error;
    }
}

// API endpoint: Generate embed token
app.post('/api/embed-token', async (req, res) => {
    try {
        const { groupId, reportId } = req.body;

        // Validate required parameters
        if (!groupId || !reportId) {
            return res.status(400).json({
                success: false,
                error: 'groupId and reportId are required in request body'
            });
        }

        console.log(`Token request: workspace=${groupId}, report=${reportId}`);

        // Get Azure AD access token
        const accessToken = await getAccessToken();

        // Use access token to generate Power BI embed token
        const embedInfo = await getEmbedToken(groupId, reportId, accessToken);

        // Return embed token to display client
        res.json({
            success: true,
            embedToken: embedInfo.token,
            embedUrl: embedInfo.embedUrl,
            expiration: embedInfo.expiration
        });

    } catch (error) {
        console.error('✗ Error in embed-token endpoint:', error.message);
        res.status(500).json({
            success: false,
            error: 'Failed to generate embed token',
            details: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
});

// Health check endpoint (for load balancers and monitoring)
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: Math.floor(process.uptime()),
        version: process.env.npm_package_version || '1.0.0',
        environment: process.env.NODE_ENV || 'production'
    });
});

// Readiness check (for Kubernetes and container orchestration)
app.get('/ready', async (req, res) => {
    try {
        // Verify we can get an access token
        await getAccessToken();
        res.json({ ready: true });
    } catch (error) {
        res.status(503).json({
            ready: false,
            error: 'Cannot acquire Azure AD token'
        });
    }
});

// Metrics endpoint (for monitoring)
app.get('/metrics', (req, res) => {
    res.json({
        uptime: Math.floor(process.uptime()),
        memory: {
            used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024),
            total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024)
        },
        timestamp: new Date().toISOString()
    });
});

// Root endpoint
app.get('/', (req, res) => {
    res.json({
        service: 'BEACON Token Service',
        version: '1.0.0',
        endpoints: {
            health: '/health',
            ready: '/ready',
            metrics: '/metrics',
            embedToken: 'POST /api/embed-token'
        }
    });
});

// 404 handler - must be after all routes
app.use((req, res) => {
    res.status(404).json({
        success: false,
        error: 'Endpoint not found',
        path: req.path,
        availableEndpoints: {
            root: 'GET /',
            health: 'GET /health',
            ready: 'GET /ready',
            metrics: 'GET /metrics',
            embedToken: 'POST /api/embed-token'
        }
    });
});

// Global error handler - must be last
app.use((err, req, res, next) => {
    console.error('[ERROR]', {
        message: err.message,
        stack: err.stack,
        path: req.path,
        method: req.method,
        ip: req.ip,
        timestamp: new Date().toISOString()
    });

    // Never expose stack traces in production
    res.status(err.status || 500).json({
        success: false,
        error: process.env.NODE_ENV === 'production'
            ? 'Internal server error'
            : err.message,
        // Include details only in development
        ...(process.env.NODE_ENV === 'development' && {
            details: err.message,
            stack: err.stack
        })
    });
});

// Validate required environment variables before starting
function validateEnvironment() {
    const required = ['TENANT_ID', 'CLIENT_ID', 'CLIENT_SECRET'];
    const missing = required.filter(key => !process.env[key]);

    if (missing.length > 0) {
        console.error('═══════════════════════════════════════════════');
        console.error('  ❌ CONFIGURATION ERROR');
        console.error('═══════════════════════════════════════════════');
        console.error('  Missing required environment variables:');
        missing.forEach(key => console.error(`    - ${key}`));
        console.error('');
        console.error('  For production deployment:');
        console.error('    - Azure: Set in App Service Configuration');
        console.error('    - AWS: Set in Elastic Beanstalk Environment');
        console.error('    - Docker: Pass with -e or use secrets');
        console.error('    - Local: Create .env file from .env.example');
        console.error('═══════════════════════════════════════════════');
        process.exit(1);
    }

    // Warn about CORS wildcard in production
    if (process.env.NODE_ENV === 'production' &&
        process.env.ALLOWED_ORIGINS === '*') {
        console.warn('═══════════════════════════════════════════════');
        console.warn('  ⚠️  SECURITY WARNING');
        console.warn('═══════════════════════════════════════════════');
        console.warn('  ALLOWED_ORIGINS is set to "*" in production!');
        console.warn('  This allows ANY website to call your API.');
        console.warn('');
        console.warn('  Recommended: Set specific origins:');
        console.warn('    ALLOWED_ORIGINS=https://display1.com,https://display2.com');
        console.warn('═══════════════════════════════════════════════');
    }
}

// Start server
const PORT = process.env.PORT || 3000;

validateEnvironment();

const server = app.listen(PORT, () => {
    console.log('═══════════════════════════════════════════════');
    console.log('  BEACON Token Service (Cloud Version)');
    console.log('═══════════════════════════════════════════════');
    console.log(`  Status: Running on port ${PORT}`);
    console.log(`  Environment: ${process.env.NODE_ENV || 'production'}`);
    console.log(`  Health: http://localhost:${PORT}/health`);
    console.log(`  API: http://localhost:${PORT}/api/embed-token`);
    console.log('═══════════════════════════════════════════════');
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM received, shutting down gracefully...');
    server.close(() => {
        console.log('Server closed');
        process.exit(0);
    });
});

process.on('SIGINT', () => {
    console.log('SIGINT received, shutting down gracefully...');
    server.close(() => {
        console.log('Server closed');
        process.exit(0);
    });
});
