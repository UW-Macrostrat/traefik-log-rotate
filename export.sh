#!/bin/sh

# This file is run on successful log rotation

# Define the log file and the rotated log file
ROTATED_LOG_FILE="$LOG_PATH.1"

# Check if the rotated log file exists
if [ -f "$ROTATED_LOG_FILE" ]; then
    echo "Log rotation successful. Processing the rotated log file."

    # Find the PID of the traefik process
    TRAEFIK_PID=$(pgrep traefik)

    # Check if the PID was found
    if [ -n "$TRAEFIK_PID" ]; then
        # Send USR1 signal to the traefik process
        kill -USR1 "$TRAEFIK_PID"
        echo "Sent USR1 signal to traefik process with PID $TRAEFIK_PID"
    else
        echo "Traefik process not found."
    fi

    # Make sure traefik has time to reopen the log file before we try to compress it
    sleep 10

    # Get the uploaded log file name
    HASH_SUFFIX=$(cksum "$ROTATED_LOG_FILE" | cut -d ' ' -f 1 | cut -c1-8)
    S3_KEY="$(date +"%Y")/$(date +"%m")/$(date +"%d")/$(date +"%H")00_HASH${HASH_SUFFIX}_access.log.zst"

    # Use a temp directory for the compressed file
    COMPRESSED_FILE="/tmp/$S3_KEY"
    COMPRESSED_FILE_DIR=$(dirname "$COMPRESSED_FILE")
    mkdir -p "$COMPRESSED_FILE_DIR"

    # Compress the rotated log before upload
    if ! zstd -19 -q -c "$ROTATED_LOG_FILE" > "$COMPRESSED_FILE"; then
        echo "Failed to compress rotated log file."
        exit 1
    fi

    # Upload the compressed log file to S3
    echo "Uploading $COMPRESSED_FILE to s3://$S3_BUCKET/$S3_KEY ..."

    /usr/local/bin/aws s3 cp "$COMPRESSED_FILE" "s3://$S3_BUCKET/$S3_KEY"

    if [ $? -ne 0 ]; then
        echo "Failed to upload log file to S3."
        exit 1
    fi

    rm -f "$COMPRESSED_FILE"

    echo "Upload to S3 successful."
else
    echo "Rotated log file not found."
    exit 1
fi
