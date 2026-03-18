# traefik-log-scraper

This service runs as a sidecar to the Traefik pod. It rotates the logs daily and sends them to the S3 for analysis. 

## The Docker Image

```bash
docker build -t traefik-log-rotate:latest .
docker run --env-file .env --rm -it -v $PWD/test-logs:/app/test-logs traefik-log-rotate:latest
```
