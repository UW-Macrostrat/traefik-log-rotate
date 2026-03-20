#!/bin/sh

echo "Running logrotate"

FORCE_ROTATE=0
for arg in "$@"; do
    case "$arg" in
        -f|--force)
            FORCE_ROTATE=1
            ;;
        *)
            echo "Unknown argument: $arg"
            echo "Usage: $0 [--force|-f]"
            exit 1
            ;;
    esac
done

TMP_LOGROTATE_CONF="/tmp/logrotate.conf"
trap 'rm -f "$TMP_LOGROTATE_CONF"' EXIT INT TERM

# Create a temporary logrotate configuration file that rotates hourly and keeps  ( 3 days ) rotated logs
cat <<EOF > "$TMP_LOGROTATE_CONF"
"$LOG_PATH" {
    hourly
    rotate 72
    compress
    delaycompress
    postrotate
        /app/export.sh
    endscript
}
EOF

cat "$TMP_LOGROTATE_CONF"

# Run logrotate with the temporary configuration file
if [ "$FORCE_ROTATE" = "1" ]; then
    echo "Force mode enabled: rotating regardless of schedule."
    /usr/sbin/logrotate -v -f "$TMP_LOGROTATE_CONF"
else
    /usr/sbin/logrotate -v "$TMP_LOGROTATE_CONF"
fi

# Clean up the temporary configuration file
rm -f "$TMP_LOGROTATE_CONF"
