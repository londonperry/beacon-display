// BEACON Display - Configuration Loader
// Loads and validates display configuration from config.json

/**
 * Load configuration from config.json
 * @returns {Promise<Object>} Configuration object
 * @throws {Error} If configuration is invalid or missing
 */
async function loadConfig() {
    try {
        updateLoadingStatus('Loading configuration...');

        // Fetch config.json from same directory
        const response = await fetch('config.json');

        if (!response.ok) {
            throw new Error(`Failed to load config.json: ${response.status} ${response.statusText}`);
        }

        const config = await response.json();

        // Validate required fields
        validateConfig(config);

        // Store in global for access by other modules
        window.beaconConfig = config;

        console.log('Configuration loaded successfully:', {
            deviceId: config.deviceId,
            tokenServiceUrl: config.tokenServiceUrl,
            groupId: config.groupId,
            reportId: config.reportId,
            refreshInterval: config.refreshIntervalSeconds,
            tokenRefresh: config.tokenRefreshMinutes
        });

        return config;

    } catch (error) {
        console.error('Configuration loading failed:', error);
        throw new Error(`Configuration error: ${error.message}`);
    }
}

/**
 * Validate configuration object
 * @param {Object} config - Configuration to validate
 * @throws {Error} If configuration is invalid
 */
function validateConfig(config) {
    // deviceId is always required
    if (!config.deviceId) {
        throw new Error('Missing required configuration field: deviceId');
    }

    // Check for public mode
    if (config.mode === 'public') {
        // Public mode only requires publicEmbedUrl
        if (!config.publicEmbedUrl) {
            throw new Error('Public mode requires publicEmbedUrl field');
        }
        console.log('Configuration validated successfully (public mode)');
        return;
    }

    // Authenticated mode requires these fields
    const required = [
        'tokenServiceUrl',
        'groupId',
        'reportId'
    ];

    const missing = required.filter(field => !config[field]);

    if (missing.length > 0) {
        throw new Error(`Missing required configuration fields: ${missing.join(', ')}`);
    }

    // Validate token service URL format
    if (!config.tokenServiceUrl.startsWith('http://') && !config.tokenServiceUrl.startsWith('https://')) {
        throw new Error('tokenServiceUrl must start with http:// or https://');
    }

    // Validate refresh intervals
    if (config.refreshIntervalSeconds && config.refreshIntervalSeconds < 10) {
        console.warn('Warning: refreshIntervalSeconds is very low (<10s), may cause performance issues');
    }

    if (config.tokenRefreshMinutes && config.tokenRefreshMinutes >= 60) {
        throw new Error('tokenRefreshMinutes must be less than 60 (token expires after 60 minutes)');
    }

    // Set defaults for optional fields
    config.refreshIntervalSeconds = config.refreshIntervalSeconds || 60;
    config.tokenRefreshMinutes = config.tokenRefreshMinutes || 50;
    config.filters = config.filters || {};

    console.log('Configuration validated successfully (authenticated mode)');
}

/**
 * Get configuration value
 * @param {string} key - Configuration key
 * @param {*} defaultValue - Default value if key doesn't exist
 * @returns {*} Configuration value
 */
function getConfig(key, defaultValue = null) {
    if (!window.beaconConfig) {
        console.error('Configuration not loaded yet');
        return defaultValue;
    }
    return window.beaconConfig[key] !== undefined ? window.beaconConfig[key] : defaultValue;
}

console.log('Config loader loaded');
