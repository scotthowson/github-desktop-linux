#!/bin/bash

set -e

PROFILE_D_FILE="/etc/profile.d/github-desktop.sh"
INSTALL_DIR="/opt/${productFilename}"
CLI_DIR="$INSTALL_DIR/resources/app/static"

case "$1" in
    configure)
      # add executable permissions for CLI interface
      chmod +x "$CLI_DIR"/github || :
      
      # check if this is a dev install or standard
      if [ -f "$INSTALL_DIR/github-desktop-dev" ]; then
        BINARY_NAME="github-desktop-dev"
      else
        BINARY_NAME="github-desktop"
      fi
      
      # create symbolic links to /usr/bin directory
      ln -f -s "$INSTALL_DIR"/$BINARY_NAME /usr/bin || :
      ln -f -s "$CLI_DIR"/github /usr/bin || :
      
      # Fix chrome-sandbox permissions (required for proper sandboxing)
      CHROME_SANDBOX="$INSTALL_DIR/chrome-sandbox"
      if [ -f "$CHROME_SANDBOX" ]; then
        echo "Setting chrome-sandbox permissions..."
        chmod 4755 "$CHROME_SANDBOX" 2>/dev/null || :
      fi
      
      # Update desktop database (for protocol handlers)
      if command -v update-desktop-database > /dev/null 2>&1; then
        echo "Updating desktop database..."
        update-desktop-database -q /usr/share/applications 2>/dev/null || :
      fi
      
      # Update mime database (for protocol handlers)
      if command -v update-mime-database > /dev/null 2>&1; then
        echo "Updating mime database..."
        update-mime-database /usr/share/mime 2>/dev/null || :
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
