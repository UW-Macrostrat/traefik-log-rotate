#!/bin/sh

echo "Running logrotate"

# Create a temporary logrotate configuration file that rotates hourly and keeps 168 ( 7 days ) rotated logs
cat <<EOF > /tmp/logrotate.conf
"$LOG_PATH" {
    hourly
    rotate 168
    compress
    delaycompress
    postrotate
        /app/export.sh
    endscript
}
EOF

cat /tmp/logrotate.conf

# Run logrotate with the temporary configuration file
/usr/sbin/logrotate -v /tmp/logrotate.conf

# Clean up the temporary configuration file
rm /tmp/logrotate.conf
