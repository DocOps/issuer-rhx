#!/bin/sh

set -e

MANPAGE_PATH="/usr/share/man/man1/issuer-rhx.1"

# This function displays the help.
# It prefers the manpage, but falls back to a simple text file if the manpage is missing or empty.
show_help() {
    if [ -s "$MANPAGE_PATH" ]; then
        man issuer-rhx
    else
        cat /usr/local/share/help.txt
    fi
}

# Check the first argument to see if it's a command we recognize.
case "$1" in
    issuer|rhx|releasehx)
        # If it's one of our tools, execute the command passed to the container.
        exec "$@"
        ;;
    *)
        # Otherwise, show the help screen.
        # This handles cases like --help, --version, or no command.
        show_help
        ;;
esac
