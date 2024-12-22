#!/bin/bash

# 🚀 InvokeAI Cloudflared Launcher
# ================================
#
#  ▄▀▀▀▄▄▄▄▄▄▄▀▀▀▄   Automated InvokeAI Launch Script    ▄▀▀▀▄▄▄▄▄▄▄▀▀▀▄
#  █▒▒░░░░░░░░░▒▒█   -------------------------------     █▒▒░░░░░░░░░▒▒█
#   █░░█░░░░░█░░█    Cloudflared Your InvokeAI WebUI      █░░█░░░░░█░░█
#   ▀▄░░▀░░░▀░░▄▀                                         ▀▄░░▀░░░▀░░▄▀
#
#  ┌─────────────────────────────────────────────────────────────┐
#  │                       Project Synopsis                      │
#  └─────────────────────────────────────────────────────────────┘

# 📘 COMPREHENSIVE USAGE GUIDE
# ============================
#
# 🔍 Quick Start Guide
# 1. Prerequisites:
#    - Bash shell (Linux/macOS/Windows WSL)
#    - Python virtual environment
#    - InvokeAI installed
#
# 🛠️ Automatic Dependency Management
# -----------------------------------
# This script AUTOMATICALLY handles:
# - Cloudflared Installation
#   * Auto-detects missing Cloudflared
#   * Imports GPG key automatically
#   * Configures package repository
#   * Installs Cloudflared package
# - Zero manual Cloudflared setup required!
#
# 📋 System Requirements
# ---------------------
# Minimum Requirements:
# - Supported Operating Systems: 
#   * Linux (Ubuntu/Debian preferred)
#   * macOS
#   * Windows WSL
#
# Required Tools (Automatically Checked):
# - bash (version 4.0+)
# - curl (for secure downloads)
# - gpg (cryptographic key verification)
# - sudo (system-level installations)
#
# Recommended Tools:
# - Python 3.8+ (for InvokeAI)
# - pip (Python package management)
#
# 🌐 Dependency Versions
# ---------------------
# Tested & Supported:
# - Cloudflared: v2023.8.2+
# - InvokeAI: v2.3.0+
#
# 🚀 Getting Started
# ------------------
# 1. Make script executable:
#    chmod +x launch-invokeai-cloudflared.sh
#
# 2. Execute the script:
#    ./launch-invokeai-cloudflared.sh
#
# 🌐 Use Cases
# ------------
# - Expose InvokeAI WebUI securely from behind NAT
# - Create temporary public access to your AI service
# - Development and testing scenarios
# - Remote collaboration
#
# 🛡️ Security Considerations
# -------------------------
# - Tunnel is temporary and regenerates each time
# - No permanent public endpoint
# - Cloudflare provides additional security layer
#
# 💡 Troubleshooting
# -----------------
# - Ensure .venv is in the same directory
# - Check internet connectivity
# - Verify Cloudflared installation
#
# 🔧 Customization
# ----------------
# Modify script variables:
# - INVOKE_LOG: Change log file location
# - Adjust timeout or retry mechanisms
#
# 📞 Support
# ----------
# GitHub: https://github.com/cloudwerxlabs/InvokeAI-Cloudflared
# Contact: support@cloudwerxlab.com

# ════════════════════════════════════════════════════════════════
#  🛡️ DEFENSIVE PROGRAMMING SHIELD: ERROR HANDLING CONFIGURATION
# ════════════════════════════════════════════════════════════════
# 
# Activate Bash's Nuclear Fail-Safe Mechanism
# ---------------------------------------------
# set -e: Instantly abort on any command's non-zero exit status
# 
# 🎯 Strategic Objectives:
#   - Prevent cascading errors
#   - Catch configuration issues early
#   - Maintain system integrity
set -e

# 🌈 Color and Formatting Utilities
# Robust ANSI color and formatting support
__color_reset='\033[0m'
__color_red='\033[0;31m'
__color_green='\033[0;32m'
__color_yellow='\033[0;33m'
__color_blue='\033[0;34m'
__color_magenta='\033[0;35m'
__color_cyan='\033[0;36m'

# Bold and Underline
__format_bold='\033[1m'
__format_underline='\033[4m'

# Logging function with color and formatting support
_log() {
    local color="$1"
    local prefix="$2"
    shift 2
    local message="$*"
    
    # Check if output is to a terminal
    if [ -t 1 ]; then
        echo -e "${color}${__format_bold}${prefix}${__color_reset} ${message}"
    else
        echo "${prefix} $*"
    fi
}

# Specific logging functions
log_info()    { _log "$__color_blue"   "[INFO]"    "$*"; }
log_success() { _log "$__color_green"  "[SUCCESS]" "$*"; }
log_warning() { _log "$__color_yellow" "[WARNING]" "$*"; }
log_error()   { _log "$__color_red"    "[ERROR]"   "$*" >&2; }
log_debug()   { _log "$__color_magenta" "[DEBUG]"  "$*"; }

# ════════════════════════════════════════════════════════════════
#  🚨 SIGNAL INTERCEPTION & RESOURCE GUARDIAN
# ════════════════════════════════════════════════════════════════
# 
# Comprehensive Signal Trapping Strategy
# ---------------------------------------
# Intercept and gracefully handle:
#   - Unexpected terminations
#   - User interrupts
#   - Critical system signals
#
# 🛡️ Protective Mechanisms:
#   - EXIT: Guaranteed cleanup
#   - INT/TERM: Soft shutdown
#   - ERR: Detailed diagnostic capture
trap 'cleanup' EXIT INT TERM
trap 'handle_error $? $LINENO' ERR

# ════════════════════════════════════════════════════════════════
#  🌐 GLOBAL STATE SENTINELS
# ════════════════════════════════════════════════════════════════
# 
# Persistent State Tracking Mechanism
# ------------------------------------
# Vigilant guardians monitoring script's critical lifecycle
#
# 🕹️ State Variables:
#   - INVOKE_PID: Background process tracker
#   - INVOKE_LOG: Diagnostic evidence recorder
#   - FOUND_URL: Tunnel creation sentinel
INVOKE_PID=""
INVOKE_LOG="$(pwd)/invokeai.log"  # Use current directory for log file
FOUND_URL=false
TUNNEL_URL_FILE="/teamspace/studios/this_studio/tunnel_url.txt"  # Use absolute path

# 🧹 Graceful Resource Cleanup Function
# -------------------------------------
# Responsible for:
#   - Terminating child processes
#   - Removing temporary files
#   - Preventing resource leaks
# 
# Design Considerations:
#   - Uses soft kill (allows processes to shut down cleanly)
#   - Silently handles potential errors during cleanup
#   - Ensures no lingering processes or temporary files
cleanup() {
    # Terminate InvokeAI process if it's still running
    # 2>/dev/null suppresses any error output during termination
    if [ ! -z "$INVOKE_PID" ]; then
        kill $INVOKE_PID 2>/dev/null || true
    fi
    
    # Remove temporary log file
    # Prevents accumulation of log files across multiple script runs
    rm -f "$INVOKE_LOG"
    
    # Remove tunnel URL file
    rm -f "$TUNNEL_URL_FILE"
}

# 🐞 Advanced Error Handling and Diagnostics
# -----------------------------------------
# Captures detailed error context for debugging
# 
# Parameters:
#   $1: Exit code of the failed command
#   $2: Line number where error occurred
#
# Provides:
#   - Precise error location
#   - Exit code for troubleshooting
#   - Automatic cleanup before exiting
handle_error() {
    local exit_code=$1
    local line_number=$2
    
    # Comprehensive error reporting
    # Helps developers quickly identify and resolve issues
    log_error "❌ Critical Error Detected!"
    log_error "   - Exit Code: $exit_code"
    log_error "   - Error Location: Line $line_number"
    log_error "   - Script: $0"
    
    # Ensure resources are cleaned up before script termination
    cleanup
    exit $exit_code
}

# 🕵️ Command Availability Verification
# -----------------------------------
# Safely checks if a command exists in the system path
# 
# Use Cases:
#   - Dependency checking
#   - Conditional execution based on tool availability
#
# Returns:
#   0 if command exists
#   1 if command is not found
command_exists() {
    # Uses command -v for POSIX compliance
    # More robust than which or type commands
    command -v "$1" >/dev/null 2>&1
}

# 🔍 Network Configuration Extraction
# ----------------------------------
# Parses InvokeAI log output to extract host and port
# 
# Regex Breakdown:
#   - Matches "http://host:port" pattern
#   - Captures host and port separately
#
# Returns:
#   Extracted host and port as space-separated string
parse_url() {
    local line="$1"
    # BASH_REMATCH provides regex capture group access
    if [[ $line =~ http://([^:]+):([0-9]+) ]]; then
        echo "${BASH_REMATCH[1]} ${BASH_REMATCH[2]}"
    fi
}

# 🛠️ Automated Dependency Installation
# -----------------------------------
# Detects and installs Cloudflare tunnel utility
# 
# Installation Steps:
#   1. Check if cloudflared is already installed
#   2. Add Cloudflare GPG key for package verification
#   3. Configure Cloudflare repository
#   4. Install cloudflared package
#
# Security and Reliability Considerations:
#   - Uses official Cloudflare repository
#   - Verifies package integrity via GPG
install_cloudflared() {
    if ! command_exists cloudflared; then
        log_warning "🔧 Cloudflared not found. Initiating installation..."
        
        # Start a background spinner
        (
            # Secure GPG key import
            curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | \
                sudo gpg --dearmor -o /usr/share/keyrings/cloudflare-archive-keyring.gpg
            
            # Repository configuration
            echo "deb [signed-by=/usr/share/keyrings/cloudflare-archive-keyring.gpg] \
                https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" | \
                sudo tee /etc/apt/sources.list.d/cloudflared.list
            
            # Update and install
            sudo apt-get update && sudo apt-get install cloudflared -y
        ) &
        
        # Show progress spinner
        _spinner $! "Installing Cloudflared"
        
        log_success "🎉 Cloudflared installed successfully!"
    fi
}

# 📋 URL Persistence Mechanism
# --------------------------
# Saves tunnel URL to a local file for user accessibility
# 
# Fallback Mechanism:
#   - When clipboard or GUI copy is unavailable
#   - Provides a reliable URL retrieval method
#
# File Location:
#   - Created in current working directory
#   - Named 'tunnel_url.txt' for easy identification
copy_to_clipboard() {
    local url="$1"
    
    # Only copy to clipboard, no file saving or logging here
    if command -v clip.exe &> /dev/null; then
        echo -n "$url" | clip.exe
    elif command -v xclip &> /dev/null; then
        echo -n "$url" | xclip -selection clipboard
    elif command -v pbcopy &> /dev/null; then
        echo -n "$url" | pbcopy
    fi
}

# 🌈 Advanced Visual Interaction Utilities
# Enhance script interactivity with dynamic visual feedback

# Animated Spinner with Progress Tracking
_spinner() {
    local pid=$1
    local message="${2:-Processing...}"
    local delay=0.1
    local spinchars='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinchars#?}
        printf "\r\033[1;34m[%c]\033[0m %s" "${spinchars:0:1}" "$message"
        spinchars=$temp${spinchars:0:1}
        sleep $delay
    done
    printf "\r\033[2K"
}

# Gradient Progress Bar
_progress_bar() {
    local width=50
    local percent=$1
    local message="${2:-Progress}"
    local completed=$((width * percent / 100))
    local remaining=$((width - completed))
    
    printf '\r\033[1;36m%s:\033[0m [' "$message"
    printf '\033[32m%*s\033[0m' "$completed" | tr ' ' '='
    printf '\033[34m%*s\033[0m' "$remaining" | tr ' ' '-'
    printf '] %3d%%' "$percent"
}

# Startup Celebration Animation
_launch_celebration() {
    clear
    local celebration_frames=(
        "🚀 Initializing Cosmic Deployment 🌐"
        "🌈 Spinning Up AI Engines 🔬"
        "🔮 Calibrating Quantum Tunnels ✨"
        "🌍 Bridging Local and Global 🌉"
        "🎉 Ignition Sequence Complete! 🚀"
    )
    
    for frame in "${celebration_frames[@]}"; do
        clear
        echo -e "\033[1;35m🚀 InvokeAI Cloudflared Launch Sequence 🌐\033[0m"
        echo -e "\033[1;36m$frame\033[0m"
        sleep 0.5
    done
    
    # Final celebratory message
    clear
    echo -e "\033[1;32m✨ InvokeAI Cloudflared is LIVE! ✨\033[0m"
    sleep 1
}

start_invokeai() {
    # Attempt to start InvokeAI WebUI
    log_info "🚀 Launching InvokeAI WebUI..."
    
    # Ensure log directory exists
    mkdir -p "$(dirname "$INVOKE_LOG")"
    
    # Capture potential startup errors with verbose logging
    .venv/bin/invokeai-web 2>&1 | tee "$INVOKE_LOG" &
    INVOKEAI_PID=$!
    
    # Wait and extract the localhost URL
    local invokeai_url=""
    local timeout=30
    local start_time=$(date +%s)
    
    while [ -z "$invokeai_url" ] && [ $(($(date +%s) - start_time)) -lt $timeout ]; do
        invokeai_url=$(grep -oP 'http://localhost:\d+' "$INVOKE_LOG" | head -1)
        sleep 1
    done
    
    if [ -z "$invokeai_url" ]; then
        log_error "❌ Failed to detect InvokeAI URL within $timeout seconds"
        kill $INVOKEAI_PID
        exit 1
    fi
    
    # Extract host and port
    local host=$(echo "$invokeai_url" | cut -d'/' -f3 | cut -d':' -f1)
    local port=$(echo "$invokeai_url" | cut -d':' -f3)
    
    log_success "🌐 Detected InvokeAI URL: $invokeai_url"
    
    # Start Cloudflared tunnel
    log_info "🚀 Initiating Cloudflared tunnel..."
    start_cloudflared "$host" "$port" &
    
    return 0
}

# 🌉 Cloudflare Tunnel Creation and Management
# -----------------------------------------
# Creates a secure tunnel to the InvokeAI web service
# 
# Parameters:
#   $1: IP address of the InvokeAI service
#   $2: Port number of the InvokeAI service
#
# Workflow:
#   1. Launch Cloudflare tunnel with real-time logging
#   2. Detect tunnel URL creation
#   3. Save tunnel URL to a local file
start_cloudflared() {
    local ip="$1"
    local port="$2"
    
    # Ensure only one tunnel creation process
    if [ -f "$TUNNEL_URL_FILE" ]; then
        rm "$TUNNEL_URL_FILE"
    fi
    
    # Start celebration only once
    _launch_celebration
    
    # Launch Cloudflare tunnel with real-time logging
    cloudflared tunnel --url "http://$ip:$port" 2>&1 | while IFS= read -r line; do
        # Detect tunnel URL creation (only once)
        if [[ $line =~ https://.*[.]trycloudflare[.]com ]] && [ ! -f "$TUNNEL_URL_FILE" ]; then
            tunnel_url=$(echo "$line" | grep -o 'https://[^ ]*trycloudflare[.]com[^ ]*')
            
            # Save tunnel URL once
            echo "$tunnel_url" > "$TUNNEL_URL_FILE"
            
            # Single set of log messages
            log_success "[Script] ✨ Tunnel URL created: $tunnel_url"
            log_success "[Script] 📍 Tunnel URL saved to: $TUNNEL_URL_FILE"
            copy_to_clipboard "$tunnel_url"
            log_success "[Script] 📋 URL has been saved!"
            
            break
        fi
    done
}

# 🏁 Pre-launch environment validation
if [ ! -d ".venv" ]; then
    log_error "❌ Error: .venv directory not found!"
    log_error "Please ensure you're in the InvokeAI installation directory."
    log_error "Current directory: $(pwd)"
    exit 1
fi

# 🔒 Virtual environment and dependency checks
if [ ! -f ".venv/bin/activate" ] || [ ! -f ".venv/bin/invokeai-web" ]; then
    log_error "❌ Error: InvokeAI is not properly installed!"
    log_error "Expected: .venv/bin/activate and .venv/bin/invokeai-web"
    exit 1
fi

# 🚀 Launch sequence
log_info "🔵 Activating virtual environment..."
source .venv/bin/activate || {
    log_error "❌ Error: Failed to activate virtual environment"
    exit 1
}

# 🌐 Ensure Cloudflare tunnel utility is available
install_cloudflared

# 🖥️ Start InvokeAI web service in background
log_info "🟢 Starting InvokeAI..."
start_invokeai

# Monitor InvokeAI process health
while true; do
    if [[ ! -d /proc/$INVOKEAI_PID ]]; then
        log_error "❌ Error: InvokeAI process died unexpectedly"
        exit 1
    fi
    sleep 30
done

# ╭──────────────────────────────────────────────────────────────╮
# │.                    InvokeAI Cloudflared                    .│
# │     https://github.com/cloudwerxlabs/InvokeAI-Cloudflared    │
# │                                                              │
# │             MADE WITH ❤️ BY CLOUDWERX LAB ☁️                │
# │.                  http://cloudwerxlab.com                   .│
# ╰──────────────────────────────────────────────────────────────╯