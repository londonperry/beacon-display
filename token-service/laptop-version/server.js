// BEACON Token Service - Laptop Version
// Generates Power BI embed tokens for display authentication
// For POC use only - runs on your development machine

require('dotenv').config();
const express = require('express');
const msal = require('@azure/msal-node');
const cors = require('cors');

const app = express();

// Security headers middleware (before other middleware)
app.use((req, res, next) => {
    // Prevent MIME type sniffing
    res.setHeader('X-Content-Type-Options', 'nosniff');

    // Prevent clickjacking
    res.setHeader('X-Frame-Options', 'DENY');

    // Enable XSS filter (legacy browsers)
    res.setHeader('X-XSS-Protection', '1; mode=block');

    // Content Security Policy for API responses
    res.setHeader('Content-Security-Policy', "default-src 'none'; frame-ancestors 'none'");

    // Remove X-Powered-By header (don't advertise Express)
    res.removeHeader('X-Powered-By');

    next();
});

// Disable X-Powered-By header globally
app.disable('x-powered-by');

// Middleware
app.use(cors()); // Allow requests from Pi (cross-origin)
app.use(express.json());

// Logging middleware
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
    next();
});

// MSAL configuration for Azure AD authentication
const msalConfig = {
    auth: {
        clientId: process.env.CLIENT_ID,        // From Azure App Registration
        authority: `https://login.microsoftonline.com/${process.env.TENANT_ID}`,
        clientSecret: process.env.CLIENT_SECRET, // Keep this secret!
    }
};

const cca = new msal.ConfidentialClientApplication(msalConfig);

// Get Azure AD access token (Step 1 of authentication)
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

// Generate Power BI embed token (Step 2 of authentication)
async function getEmbedToken(groupId, reportId, accessToken) {
    const embedUrl = `https://api.powerbi.com/v1.0/myorg/groups/${groupId}/reports/${reportId}`;
    
    try {
        // Call Power BI API to generate embed token
        const response = await fetch(`${embedUrl}/GenerateToken`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${accessToken}`
            },
            body: JSON.stringify({
                accessLevel: 'View' // Read-only access
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

// Main API endpoint: Generate embed token
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

        // Step 1: Get Azure AD access token
        const accessToken = await getAccessToken();

        // Step 2: Use access token to generate Power BI embed token
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
            details: error.message 
        });
    }
});

// Health check endpoint (for testing)
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: Math.floor(process.uptime())
    });
});

// 404 handler - must be after all routes
app.use((req, res) => {
    res.status(404).json({
        success: false,
        error: 'Endpoint not found',
        availableEndpoints: {
            health: 'GET /health',
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
        method: req.method
    });

    // Don't expose internal errors to client
    res.status(err.status || 500).json({
        success: false,
        error: err.message || 'Internal server error',
        // Include details in development mode only
        ...(process.env.NODE_ENV === 'development' && {
            stack: err.stack,
            details: err.toString()
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
        console.error('  Please check your .env file:');
        console.error('    1. Ensure .env file exists (copy from .env.example)');
        console.error('    2. Fill in all required values');
        console.error('    3. Restart the server');
        console.error('═══════════════════════════════════════════════');
        process.exit(1);
    }
}

// Start server
const PORT = process.env.PORT || 3000;

validateEnvironment();

app.listen(PORT, () => {
    console.log('═══════════════════════════════════════════════');
    console.log('  BEACON Token Service (Laptop Version)');
    console.log('═══════════════════════════════════════════════');
    console.log(`  Status: Running on port ${PORT}`);
    console.log(`  Health: http://localhost:${PORT}/health`);
    console.log(`  API:    http://localhost:${PORT}/api/embed-token`);
    console.log('═══════════════════════════════════════════════');
    console.log('  Keep this terminal open while testing');
    console.log('  Press Ctrl+C to stop');
    console.log('═══════════════════════════════════════════════');
});
