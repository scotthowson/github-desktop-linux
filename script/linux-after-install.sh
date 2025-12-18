#!/bin/bash

set -e

INSTALL_DIR="/opt/github-desktop"
CLI_DIR="$INSTALL_DIR/resources/app/static"

case "$1" in
    configure)
      # Set proper directory permissions (755 = rwxr-xr-x)
      chmod 755 "$INSTALL_DIR"
      
      # Determine binary name (dev or standard)
      if [ -f "$INSTALL_DIR/github-desktop-dev" ]; then
        BINARY_NAME="github-desktop-dev"
      else
        BINARY_NAME="github-desktop"
      fi
      
      # Ensure main binary is executable
      if [ -f "$INSTALL_DIR/$BINARY_NAME" ]; then
        chmod 755 "$INSTALL_DIR/$BINARY_NAME"
        echo "Set executable permissions for $BINARY_NAME"
      fi
      
      # Ensure CLI is executable (if it exists)
      if [ -f "$CLI_DIR/github" ]; then
        chmod 755 "$CLI_DIR/github" || :
      fi
      
      # Create symbolic links to /usr/bin
      ln -sf "$INSTALL_DIR/$BINARY_NAME" /usr/bin/github-desktop
      echo "Created symlink: /usr/bin/github-desktop -> $INSTALL_DIR/$BINARY_NAME"
      
      if [ -f "$CLI_DIR/github" ]; then
        ln -sf "$CLI_DIR/github" /usr/bin/github
        echo "Created symlink: /usr/bin/github -> $CLI_DIR/github"
      fi
      
      # Fix chrome-sandbox permissions
      CHROME_SANDBOX="$INSTALL_DIR/chrome-sandbox"
      if [ -f "$CHROME_SANDBOX" ]; then
        chmod 4755 "$CHROME_SANDBOX" 2>/dev/null || {
          echo "Warning: Could not set chrome-sandbox permissions (requires root)"
        }
      fi
      
      # Update desktop database
      if command -v update-desktop-database > /dev/null 2>&1; then
        update-desktop-database -q /usr/share/applications 2>/dev/null || :
      fi
      
      # Update MIME database
      if command -v update-mime-database > /dev/null 2>&1; then
        update-mime-database /usr/share/mime 2>/dev/null || :
      fi
      
      # Register protocol handlers
      if command -v xdg-mime > /dev/null 2>&1; then
        xdg-mime default github-desktop.desktop x-scheme-handler/x-github-client 2>/dev/null || :
        xdg-mime default github-desktop.desktop x-scheme-handler/x-github-desktop-auth 2>/dev/null || :
        xdg-mime default github-desktop.desktop x-scheme-handler/x-github-desktop-dev-auth 2>/dev/null || :
        echo "Registered protocol handlers"
      fi
      
      echo "GitHub Desktop installation complete!"
    ;;

    abort-upgrade|abort-remove|abort-deconfigure)
    ;;

    *)
      echo "postinst called with unknown argument \`$1'" >&2
      exit 1
    ;;
esac

exit 0
