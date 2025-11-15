#!/bin/bash
# BEACON Display - Hardware Detection and Abstraction Layer
# Provides device-agnostic functions for different hardware platforms

detect_hardware() {
    # Detect device type based on hardware identifiers
    if [ -f /proc/device-tree/model ]; then
        DEVICE_MODEL=$(cat /proc/device-tree/model)

        # Raspberry Pi detection
        if echo "$DEVICE_MODEL" | grep -qi "Raspberry Pi Zero 2"; then
            echo "pi-zero-2w"
        elif echo "$DEVICE_MODEL" | grep -qi "Raspberry Pi 4"; then
            echo "pi-4"
        elif echo "$DEVICE_MODEL" | grep -qi "Raspberry Pi 5"; then
            echo "pi-5"
        elif echo "$DEVICE_MODEL" | grep -qi "Raspberry Pi"; then
            echo "raspberry-pi"
        fi
    # Check for x86/Intel
    elif [ -f /proc/cpuinfo ] && grep -qi "Intel" /proc/cpuinfo; then
        echo "intel-nuc"
    # Check for Rockchip (Orange Pi)
    elif [ -f /proc/cpuinfo ] && grep -qi "Rockchip" /proc/cpuinfo; then
        echo "orange-pi"
    else
        echo "unknown"
    fi
}

get_memory_total() {
    # Get total system memory in MB
    free -m | awk '/^Mem:/ {print $2}'
}

get_memory_threshold() {
    # Calculate 85% memory threshold for watchdog
    TOTAL_MEM=$(get_memory_total)
    echo $((TOTAL_MEM * 85 / 100))
}

get_temperature() {
    # Get CPU temperature in Celsius (device-specific)
    DEVICE_TYPE=$(detect_hardware)

    case "$DEVICE_TYPE" in
        pi-*|raspberry-pi)
            # Raspberry Pi specific - uses vcgencmd
            if command -v vcgencmd > /dev/null 2>&1; then
                vcgencmd measure_temp | grep -oE '[0-9]*\.[0-9]*'
            else
                echo "N/A"
            fi
            ;;
        intel-nuc|orange-pi|unknown)
            # Generic Linux thermal zone
            if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
                TEMP_MILLIDEGREE=$(cat /sys/class/thermal/thermal_zone0/temp)
                # Convert from millidegrees to degrees
                awk "BEGIN {printf \"%.1f\", $TEMP_MILLIDEGREE / 1000}"
            else
                echo "N/A"
            fi
            ;;
        *)
            echo "N/A"
            ;;
    esac
}

get_chromium_command() {
    # Find available Chromium binary (varies by distro)
    for cmd in chromium-browser chromium google-chrome chrome; do
        if command -v $cmd > /dev/null 2>&1; then
            echo "$cmd"
            return
        fi
    done
    echo "chromium-browser"  # Fallback
}

get_recommended_memory_limit() {
    # Calculate optimal memory limit for systemd service
    TOTAL_MEM=$(get_memory_total)

    # Leave 100-200MB for system, depending on total RAM
    if [ "$TOTAL_MEM" -lt 1024 ]; then
        # Low memory systems (< 1GB): leave 100MB
        LIMIT=$((TOTAL_MEM - 100))
    else
        # Higher memory systems: leave 200MB
        LIMIT=$((TOTAL_MEM - 200))
    fi

    # Cap at 2GB (display doesn't need more)
    if [ "$LIMIT" -gt 2000 ]; then
        LIMIT=2000
    fi

    echo "${LIMIT}M"
}

get_device_info() {
    # Print comprehensive device information
    DEVICE_TYPE=$(detect_hardware)
    TOTAL_MEM=$(get_memory_total)
    TEMP=$(get_temperature)
    CHROMIUM=$(get_chromium_command)
    MEM_LIMIT=$(get_recommended_memory_limit)

    echo "Device Type: $DEVICE_TYPE"
    echo "Total Memory: ${TOTAL_MEM}MB"
    echo "CPU Temperature: ${TEMP}°C"
    echo "Chromium Binary: $CHROMIUM"
    echo "Recommended Memory Limit: $MEM_LIMIT"
}

# Export functions for use in other scripts
export -f detect_hardware
export -f get_memory_total
export -f get_memory_threshold
export -f get_temperature
export -f get_chromium_command
export -f get_recommended_memory_limit
export -f get_device_info
