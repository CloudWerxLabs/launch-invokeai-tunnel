#!/bin/bash

#   ╔═══════════════════════════════════════════════════════════════╗
#   ║               🚀 InvokeAI Tunnel Launcher 🌐                 ║
#   ╚═══════════════════════════════════════════════════════════════╝
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
    echo "❌ Critical Error Detected!"
    echo "   - Exit Code: $exit_code"
    echo "   - Error Location: Line $line_number"
    echo "   - Script: $0"
    
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
        echo "🔧 Cloudflared not found. Initiating installation..."
        
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
    echo "[Script] 📍 Tunnel URL saved to: $(pwd)/tunnel_url.txt"
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
        echo "[Cloudflare] $line"
        
        # Detect tunnel URL creation
        if [[ $line =~ https://.*[.]trycloudflare[.]com ]]; then
            tunnel_url=$(echo "$line" | grep -o 'https://[^ ]*trycloudflare[.]com[^ ]*')
            echo "[Script] 🚧 Tunnel created, will show URL in 5 seconds..."
            (
                # Delayed URL display to allow tunnel stabilization
                sleep 5
                echo -e "\n[Script] ✨ Tunnel URL created: $tunnel_url"
                copy_to_clipboard "$tunnel_url"
                echo "[Script] 📋 URL has been saved!"
            ) &
        fi
    done
}

# 🏁 Pre-launch environment validation
if [ ! -d ".venv" ]; then
    echo "❌ Error: .venv directory not found!"
    echo "Please ensure you're in the InvokeAI installation directory."
    echo "Current directory: $(pwd)"
    exit 1
fi

# 🔒 Virtual environment and dependency checks
if [ ! -f ".venv/bin/activate" ] || [ ! -f ".venv/bin/invokeai-web" ]; then
    echo "❌ Error: InvokeAI is not properly installed!"
    echo "Expected: .venv/bin/activate and .venv/bin/invokeai-web"
    exit 1
fi

# 🚀 Launch sequence
echo "🔵 Activating virtual environment..."
source .venv/bin/activate || {
    echo "❌ Error: Failed to activate virtual environment"
    exit 1
}

# 🌐 Ensure Cloudflare tunnel utility is available
install_cloudflared

# 🖥️ Start InvokeAI web service in background
echo "🟢 Starting InvokeAI..."
.venv/bin/invokeai-web > "$INVOKE_LOG" 2>&1 &
INVOKE_PID=$!

# 🕵️ Monitor InvokeAI logs and initiate tunnel
monitor_and_start_tunnel() {
    local ip=""
    local port=""
    
    # Continuous monitoring with process health check
    while true; do
        if [[ ! -d /proc/$INVOKE_PID ]]; then
            echo "❌ Error: InvokeAI process died unexpectedly"
            exit 1
        fi
        
        # Real-time log parsing
        while IFS= read -r line; do
            echo "[InvokeAI] $line"
            
            # Detect InvokeAI startup and extract connection details
            if [[ $line == *"Invoke running on"* ]] && [[ $FOUND_URL == false ]]; then
                FOUND_URL=true
                read ip port <<< $(parse_url "$line")
                echo -e "\n[Script] 🚀 Found InvokeAI running on $ip:$port"
                echo "[Script] 🌉 Starting Cloudflare tunnel..."
                
                # Initiate tunnel creation
                start_cloudflared "$ip" "$port"
                exit 0
            fi
        done < <(tail -f "$INVOKE_LOG")
    done
}

# 🚀 Launch monitoring and tunneling process
monitor_and_start_tunnel