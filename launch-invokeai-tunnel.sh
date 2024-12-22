#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════╗
# ║         🚀 Made with <4 by CLOUDWERX LAB 🌐               ║
# ╚═══════════════════════════════════════════════════════════════╝
#
#  ▄▀▀▀▄▄▄▄▄▄▄▀▀▀▄  Automated AI Service Deployment Wizard  ▄▀▀▀▄▄▄▄▄▄▄▀▀▀▄
#  █▒▒░░░░░░░░░▒▒█  -------------------------------         █▒▒░░░░░░░░░▒▒█
#   █░░█░░░░░█░░█   Transforming Local AI into Global Magic  █░░█░░░░░█░░█
#   ▀▄░░▀░░░▀░░▄▀                                            ▀▄░░▀░░░▀░░▄▀
#
#   ┌─────────────────────────────────────────────────────────────┐
#   │                       Project Synopsis                      │
#   └─────────────────────────────────────────────────────────────┘
#
# 🌈 Mission Control:
#   - Automate InvokeAI web service deployment
#   - Create secure, global network tunnels
#   - Provide bulletproof error management
#
# 🛡️ Core Architectural Principles:
#   ✓ Cross-platform bash scripting
#   ✓ Zero-configuration networking
#   ✓ Robust failure detection
#
# 🚀 Deployment Workflow:
#   1. 🔒 Virtual Environment Validation
#   2. 🔌 Environment Activation
#   3. 🖥️ Web Service Launch
#   4. 🌐 Network Detection
#   5. 🌉 Secure Tunneling
#   6. 🔗 Public URL Generation
#
# 🔗 Critical Dependencies:
#   - Python Virtual Environment
#   - InvokeAI Web Service
#   - Cloudflared Tunnel Utility
#
# 🛡️ Security Fortress:
#   - Ephemeral log management
#   - Signed package installations
#   - Controlled URL exposure
#
# ╭──────────────────────────────────────────────────────────────╮
# │           Crafted with 💖 by AI Infrastructure Wizards      │
# ╰──────────────────────────────────────────────────────────────╯

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
INVOKE_LOG="/tmp/invokeai.$$.log"  # Unique forensic log per execution
FOUND_URL=false

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
        log_info "🔧 Cloudflared not found. Initiating installation..."
        
        # Secure GPG key import
        curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | \
            sudo gpg --dearmor -o /usr/share/keyrings/cloudflare-archive-keyring.gpg
        
        # Repository configuration with signed-by for security
        echo "deb [signed-by=/usr/share/keyrings/cloudflare-archive-keyring.gpg] \
            https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" | \
            sudo tee /etc/apt/sources.list.d/cloudflared.list
        
        # Update and install with error handling
        sudo apt-get update && sudo apt-get install cloudflared -y
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
    
    # Write URL to file with minimal overhead
    echo -n "$url" > "tunnel_url.txt"
    
    # Provide clear user feedback
    log_success "[Script] 📍 Tunnel URL saved to: $(pwd)/tunnel_url.txt"
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
    
    # Launch Cloudflare tunnel with real-time logging
    cloudflared tunnel --url "http://$ip:$port" 2>&1 | while IFS= read -r line; do
        log_info "[Cloudflare] $line"
        
        # Detect tunnel URL creation
        if [[ $line =~ https://.*[.]trycloudflare[.]com ]]; then
            tunnel_url=$(echo "$line" | grep -o 'https://[^ ]*trycloudflare[.]com[^ ]*')
            log_info "[Script] 🚧 Tunnel created, will show URL in 5 seconds..."
            (
                # Delayed URL display to allow tunnel stabilization
                sleep 5
                log_success "[Script] ✨ Tunnel URL created: $tunnel_url"
                copy_to_clipboard "$tunnel_url"
                log_success "[Script] 📋 URL has been saved!"
            ) &
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
.venv/bin/invokeai-web > "$INVOKE_LOG" 2>&1 &
INVOKE_PID=$!

# 🕵️ Monitor InvokeAI logs and initiate tunnel
monitor_and_start_tunnel() {
    local ip=""
    local port=""
    
    # Continuous monitoring with process health check
    while true; do
        if [[ ! -d /proc/$INVOKE_PID ]]; then
            log_error "❌ Error: InvokeAI process died unexpectedly"
            exit 1
        fi
        
        # Real-time log parsing
        while IFS= read -r line; do
            log_info "[InvokeAI] $line"
            
            # Detect InvokeAI startup and extract connection details
            if [[ $line == *"Invoke running on"* ]] && [[ $FOUND_URL == false ]]; then
                FOUND_URL=true
                read ip port <<< $(parse_url "$line")
                log_success "[Script] 🚀 Found InvokeAI running on $ip:$port"
                log_info "[Script] 🌉 Starting Cloudflare tunnel..."
                
                # Initiate tunnel creation
                start_cloudflared "$ip" "$port"
                exit 0
            fi
        done < <(tail -f "$INVOKE_LOG")
    done
}

# 🚀 Launch monitoring and tunneling process
monitor_and_start_tunnel

# ╭──────────────────────────────────────────────────────────────╮
# │       🚀 CLOUDWERX LAB: Empowering AI Infrastructure 🌐     │
# │           https://github.com/cloudwerx/launch-tools         │
# │                                                             │
# │           Crafted with <4 in the Cloud ☁️                   │
# ╰──────────────────────────────────────────────────────────────╯