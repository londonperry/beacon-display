// BEACON Display - Error Handler
// Manages error display and user-friendly messaging

/**
 * Show error screen with user-friendly message
 * @param {string} title - Error title
 * @param {string} message - User-friendly error message
 * @param {string} details - Technical details (optional)
 */
function showError(title, message, details = '') {
    console.error('Display Error:', title, message, details);

    // Hide loading and report container
    document.getElementById('loading').style.display = 'none';
    document.getElementById('reportContainer').classList.remove('visible');

    // Show error screen
    const errorDiv = document.getElementById('error');
    const errorMessage = document.getElementById('errorMessage');
    const errorDetails = document.getElementById('errorDetails');

    errorDiv.querySelector('h1').textContent = `⚠️ ${title}`;
    errorMessage.textContent = message;

    if (details) {
        errorDetails.textContent = details;
        errorDetails.style.display = 'block';
    } else {
        errorDetails.style.display = 'none';
    }

    errorDiv.classList.add('visible');
}

/**
 * Hide loading screen and show report
 */
function showReport() {
    document.getElementById('loading').style.display = 'none';
    document.getElementById('error').classList.remove('visible');
    document.getElementById('reportContainer').classList.add('visible');
}

/**
 * Update loading status message
 * @param {string} message - Status message to display
 */
function updateLoadingStatus(message) {
    const statusElement = document.querySelector('#loading .status');
    if (statusElement) {
        statusElement.textContent = message;
    }
    console.log('Status:', message);
}

/**
 * Convert error to user-friendly message
 * @param {Error} error - JavaScript error object
 * @returns {Object} Object with title, message, and details
 */
function getUserFriendlyError(error) {
    const errorStr = error.toString().toLowerCase();

    // Network errors
    if (errorStr.includes('failed to fetch') || errorStr.includes('network')) {
        return {
            title: 'Network Error',
            message: 'Cannot connect to token service. Please ensure the service is running and network is available.',
            details: `Token service URL: ${window.beaconConfig?.tokenServiceUrl || 'not configured'}\n\nError: ${error.message}`
        };
    }

    // Configuration errors
    if (errorStr.includes('config') || errorStr.includes('not found')) {
        return {
            title: 'Configuration Error',
            message: 'Display configuration is missing or invalid. Please check config.json file.',
            details: error.message
        };
    }

    // Authentication errors
    if (errorStr.includes('unauthorized') || errorStr.includes('403') || errorStr.includes('401')) {
        return {
            title: 'Authentication Error',
            message: 'Cannot authenticate with Power BI. Please verify Azure credentials and workspace permissions.',
            details: error.message
        };
    }

    // Power BI API errors
    if (errorStr.includes('power bi') || errorStr.includes('embed')) {
        return {
            title: 'Power BI Error',
            message: 'Failed to load Power BI report. Please verify report ID and workspace permissions.',
            details: error.message
        };
    }

    // Token service errors
    if (errorStr.includes('token')) {
        return {
            title: 'Token Generation Error',
            message: 'Failed to generate embed token. Please check token service logs and Azure configuration.',
            details: error.message
        };
    }

    // Generic error
    return {
        title: 'System Error',
        message: 'An unexpected error occurred. Display will retry automatically.',
        details: error.message
    };
}

/**
 * Global error handler for uncaught errors
 */
window.addEventListener('error', (event) => {
    console.error('Uncaught error:', event.error);
    const errorInfo = getUserFriendlyError(event.error);
    showError(errorInfo.title, errorInfo.message, errorInfo.details);
});

/**
 * Global handler for unhandled promise rejections
 */
window.addEventListener('unhandledrejection', (event) => {
    console.error('Unhandled rejection:', event.reason);
    const errorInfo = getUserFriendlyError(event.reason);
    showError(errorInfo.title, errorInfo.message, errorInfo.details);
});

console.log('Error handler loaded');
