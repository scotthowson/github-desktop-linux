#!/bin/bash
set -e

PROFILE_D_FILE="/etc/profile.d/github-desktop.sh"
BASE_FILE="/usr/bin/github"

case "$1" in
    purge|remove|upgrade|failed-upgrade|abort-install|abort-upgrade|disappear)
      echo "#!/bin/sh" > "${PROFILE_D_FILE}";
      . "${PROFILE_D_FILE}";
      rm "${PROFILE_D_FILE}";
      
      # remove symbolic links in /usr/bin directory
      test -f ${BASE_FILE} && unlink ${BASE_FILE}
      test -f ${BASE_FILE}-desktop && unlink ${BASE_FILE}-desktop
      test -f ${BASE_FILE}-desktop-dev && unlink ${BASE_FILE}-desktop-dev
      
      # Update desktop database
      if command -v update-desktop-database > /dev/null 2>&1; then
        update-desktop-database -q /usr/share/applications 2>/dev/null || :
      fi
      
      # Update mime database
      if command -v update-mime-database > /dev/null 2>&1; then
        update-mime-database /usr/share/mime 2>/dev/null || :
      fi
      
      echo "GitHub Desktop removed successfully!"
    ;;

    *)
      echo "postrm called with unknown argument \`$1'" >&2
      exit 1
    ;;
esac

exit 0
