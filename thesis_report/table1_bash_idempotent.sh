#!/bin/bash
# Imperative (idempotent): Ensure app config exists
# Must manually check every condition!

CHANGED=false
CONFIG_PATH="./myapp/config.ini"
DESIRED_CONTENT="debug=false
port=8080"

# Ensure directory exists
if [ ! -d ./myapp ]; then
    mkdir -p ./myapp
    CHANGED=true
fi

# Ensure file content matches
if [ ! -f "$CONFIG_PATH" ]; then
    echo "$DESIRED_CONTENT" > "$CONFIG_PATH"
    CHANGED=true
elif [ "$(cat "$CONFIG_PATH")" != "$DESIRED_CONTENT" ]; then
    echo "$DESIRED_CONTENT" > "$CONFIG_PATH"
    CHANGED=true
fi

# Ensure ownership
CURRENT_OWNER=$(stat -c '%U:%G' "$CONFIG_PATH" 2>/dev/null)
if [ "$CURRENT_OWNER" != "appuser:appuser" ]; then
    chown appuser:appuser "$CONFIG_PATH"
    CHANGED=true
fi

# Ensure permissions
CURRENT_PERMS=$(stat -c '%a' "$CONFIG_PATH" 2>/dev/null)
if [ "$CURRENT_PERMS" != "644" ]; then
    chmod 644 "$CONFIG_PATH"
    CHANGED=true
fi

if [ "$CHANGED" = true ]; then
    echo "Configuration updated"
else
    echo "Already configured"
fi
