// BEACON Display - Power BI Embed Integration
// Handles Power BI report embedding, authentication, and auto-refresh

// Global Power BI service instance and report reference
let powerbi;
let embeddedReport;
let currentEmbedToken;
let tokenRefreshTimer;
let dataRefreshTimer;

/**
 * Initialize Power BI display with given configuration
 * @param {Object} config - Display configuration
 */
async function initializePowerBIDisplay(config) {
    try {
        updateLoadingStatus('Initializing Power BI...');

        // Get Power BI service instance
        powerbi = window.powerbi;
        if (!powerbi) {
            throw new Error('Power BI JavaScript library not loaded. Check CDN connection.');
        }

        // Check if public mode (no authentication needed)
        if (config.mode === 'public' && config.publicEmbedUrl) {
            updateLoadingStatus('Loading public report...');
            await embedPublicReport(config);
            showReport();
            console.log('Public Power BI display initialized successfully');
            return;
        }

        // Authenticated mode - get embed token from token service
        updateLoadingStatus('Requesting authentication token...');
        const embedInfo = await requestEmbedToken(config);

        // Embed the report
        updateLoadingStatus('Loading report...');
        await embedReport(config, embedInfo);

        // Start auto-refresh timers
        startAutoRefresh(config);

        // Show the report
        showReport();

        console.log('Power BI display initialized successfully');

    } catch (error) {
        console.error('Power BI initialization failed:', error);

        // Clean up any partial state
        cleanupPowerBI();

        const errorInfo = getUserFriendlyError(error);
        showError(errorInfo.title, errorInfo.message, errorInfo.details);
        throw error;
    }
}

/**
 * Embed public Power BI report (no authentication)
 * @param {Object} config - Display configuration with publicEmbedUrl
 */
async function embedPublicReport(config) {
    try {
        const embedContainer = document.getElementById('reportContainer');

        // Public reports use iframe embedding
        embedContainer.innerHTML = `
            <iframe
                src="${config.publicEmbedUrl}"
                frameborder="0"
                allowFullScreen="true"
                style="width: 100%; height: 100%; border: none;">
            </iframe>
        `;

        console.log('Public report embedded successfully');

    } catch (error) {
        console.error('Public report embedding failed:', error);
        throw error;
    }
}

/**
 * Request embed token from token service with retry logic
 * @param {Object} config - Display configuration
 * @param {number} retries - Number of retries remaining (default 3)
 * @returns {Promise<Object>} Embed token information
 */
async function requestEmbedToken(config, retries = 3) {
    const maxRetries = 3;
    const retryDelay = 2000; // 2 seconds between retries

    for (let attempt = 1; attempt <= maxRetries; attempt++) {
        try {
            console.log(`Requesting embed token from: ${config.tokenServiceUrl} (attempt ${attempt}/${maxRetries})`);

            const response = await fetch(config.tokenServiceUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    groupId: config.groupId,
                    reportId: config.reportId
                })
            });

            if (!response.ok) {
                const errorText = await response.text();
                throw new Error(`Token service returned ${response.status}: ${errorText}`);
            }

            const data = await response.json();

            if (!data.success || !data.embedToken) {
                throw new Error(`Token service error: ${data.error || 'Unknown error'}`);
            }

            console.log('Embed token received successfully');
            console.log('Token expires:', data.expiration);

            return {
                token: data.embedToken,
                embedUrl: data.embedUrl,
                expiration: data.expiration
            };

        } catch (error) {
            console.error(`Token request attempt ${attempt} failed:`, error.message);

            // If this was the last attempt, throw the error
            if (attempt === maxRetries) {
                throw new Error(`Token request failed after ${maxRetries} attempts: ${error.message}`);
            }

            // Wait before retrying (exponential backoff)
            const delay = retryDelay * attempt;
            console.log(`Retrying in ${delay}ms...`);
            await new Promise(resolve => setTimeout(resolve, delay));
        }
    }
}

/**
 * Embed Power BI report in the container
 * @param {Object} config - Display configuration
 * @param {Object} embedInfo - Embed token information
 */
async function embedReport(config, embedInfo) {
    try {
        const embedContainer = document.getElementById('reportContainer');

        // Build embed configuration
        const embedConfig = {
            type: 'report',
            tokenType: powerbi.models.TokenType.Embed,
            accessToken: embedInfo.token,
            embedUrl: embedInfo.embedUrl,
            id: config.reportId,
            permissions: powerbi.models.Permissions.Read,
            settings: {
                // Full-screen display settings
                panes: {
                    filters: { visible: false },      // Hide filter pane
                    pageNavigation: { visible: false } // Hide page navigation
                },
                background: powerbi.models.BackgroundType.Transparent,
                layoutType: powerbi.models.LayoutType.Custom,
                customLayout: {
                    displayOption: powerbi.models.DisplayOption.FitToWidth
                }
            },
            // Apply filters if specified in config
            filters: buildFilters(config.filters)
        };

        console.log('Embedding report with config:', {
            reportId: config.reportId,
            embedUrl: embedInfo.embedUrl,
            hasFilters: embedConfig.filters.length > 0
        });

        // Embed the report
        embeddedReport = powerbi.embed(embedContainer, embedConfig);
        currentEmbedToken = embedInfo.token;

        // Wait for report to load
        await new Promise((resolve, reject) => {
            let loaded = false;

            // Success handler
            embeddedReport.on('loaded', () => {
                if (!loaded) {
                    loaded = true;
                    console.log('Report loaded successfully');
                    resolve();
                }
            });

            // Error handler
            embeddedReport.on('error', (event) => {
                if (!loaded) {
                    loaded = true;
                    console.error('Report loading error:', event.detail);
                    reject(new Error(`Power BI error: ${JSON.stringify(event.detail)}`));
                }
            });

            // Timeout after 30 seconds
            setTimeout(() => {
                if (!loaded) {
                    loaded = true;
                    reject(new Error('Report loading timeout (30s)'));
                }
            }, 30000);
        });

        console.log('Report embedded successfully');

    } catch (error) {
        console.error('Report embedding failed:', error);
        throw error;
    }
}

/**
 * Build Power BI filters from config filters object
 * @param {Object} filters - Filter configuration
 * @returns {Array} Power BI filter array
 */
function buildFilters(filters) {
    if (!filters || Object.keys(filters).length === 0) {
        return [];
    }

    // Example: { storeId: "001" } becomes filter on storeId field
    // Customize this based on your report structure
    return Object.entries(filters).map(([field, value]) => ({
        $schema: "http://powerbi.com/product/schema#basic",
        target: {
            table: "Sales", // Change to your table name
            column: field
        },
        operator: "In",
        values: [value]
    }));
}

/**
 * Start auto-refresh timers for data and token
 * @param {Object} config - Display configuration
 */
function startAutoRefresh(config) {
    let dataRefreshFailures = 0;
    const maxDataRefreshFailures = 3;

    // Data refresh timer (updates report data without reloading)
    const dataRefreshMs = config.refreshIntervalSeconds * 1000;
    console.log(`Starting data auto-refresh: every ${config.refreshIntervalSeconds} seconds`);

    dataRefreshTimer = setInterval(async () => {
        try {
            console.log('Refreshing report data...');
            await embeddedReport.refresh();
            console.log('Report data refreshed successfully');

            // Reset failure counter on success
            if (dataRefreshFailures > 0) {
                dataRefreshFailures = 0;
                updateStatus('Data refresh recovered', 'ok');
            }
        } catch (error) {
            dataRefreshFailures++;
            console.error(`Data refresh failed (${dataRefreshFailures}/${maxDataRefreshFailures}):`, error);

            // Show warning if multiple failures
            if (dataRefreshFailures >= maxDataRefreshFailures) {
                updateStatus('Data refresh failing - report may be stale', 'error');
            } else {
                updateStatus('Data refresh error - retrying...', 'warning');
            }

            // Don't throw - will retry on next interval
        }
    }, dataRefreshMs);

    // Token refresh timer (refreshes embed token before expiry)
    const tokenRefreshMs = config.tokenRefreshMinutes * 60 * 1000;
    console.log(`Starting token auto-refresh: every ${config.tokenRefreshMinutes} minutes`);

    tokenRefreshTimer = setInterval(async () => {
        try {
            console.log('Refreshing embed token...');
            await refreshEmbedToken(config);
            console.log('Embed token refreshed successfully');
            updateStatus('Token refreshed', 'ok');
        } catch (error) {
            console.error('Token refresh failed:', error);
            // Critical error - show error screen
            const errorInfo = getUserFriendlyError(error);
            showError(errorInfo.title, errorInfo.message, errorInfo.details);

            // Reload page after 30 seconds
            setTimeout(() => {
                window.location.reload();
            }, 30000);
        }
    }, tokenRefreshMs);
}

/**
 * Refresh embed token before expiry
 * @param {Object} config - Display configuration
 */
async function refreshEmbedToken(config) {
    try {
        // Request new token
        const embedInfo = await requestEmbedToken(config);

        // Update token in embedded report
        await embeddedReport.setAccessToken(embedInfo.token);

        currentEmbedToken = embedInfo.token;
        console.log('Token updated in embedded report');

    } catch (error) {
        console.error('Token refresh error:', error);
        throw error;
    }
}

/**
 * Cleanup function (call before page unload or on error)
 */
function cleanupPowerBI() {
    console.log('Cleaning up Power BI resources...');

    // Clear timers
    if (tokenRefreshTimer) {
        clearInterval(tokenRefreshTimer);
        tokenRefreshTimer = null;
        console.log('Token refresh timer cleared');
    }
    if (dataRefreshTimer) {
        clearInterval(dataRefreshTimer);
        dataRefreshTimer = null;
        console.log('Data refresh timer cleared');
    }

    // Reset embedded report
    if (embeddedReport && powerbi) {
        try {
            powerbi.reset(document.getElementById('reportContainer'));
            embeddedReport = null;
            console.log('Embedded report reset');
        } catch (error) {
            console.error('Error resetting report:', error);
        }
    }

    // Clear token reference
    currentEmbedToken = null;

    console.log('Power BI cleanup completed');
}

// Cleanup on page unload
window.addEventListener('beforeunload', cleanupPowerBI);

console.log('Power BI embed module loaded');
