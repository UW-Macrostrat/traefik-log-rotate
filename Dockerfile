FROM python:3.14

# Install cron
RUN apt-get update -y && apt-get install -y cron logrotate

# Install aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.17.13.zip" -o "awscliv2.zip" && \
  unzip awscliv2.zip && \
  ./aws/install --update

# Set the working directory
WORKDIR /app

# Copy the necessary files
COPY ./export.sh export.sh
COPY ./logrotate.sh logrotate.sh
COPY ./crontab /etc/cron.d/import-cron

# Make the scripts executable
RUN chmod +x export.sh logrotate.sh

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/import-cron

# Apply cron job
RUN crontab /etc/cron.d/import-cron

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Start the cron service and the application
CMD printenv > /etc/environment && cron && tail -f /var/log/cron.log
