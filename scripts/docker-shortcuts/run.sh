#!/usr/bin/env bash

# Build
echo "🤖 Build"
docker build -f ./docker/run/Dockerfile -t apicore .

# Run
echo "🏃‍♀️ Run"
docker run \
    -e APICORE_DATABASE_HOST=docker.for.mac.host.internal \
    -e APICORE_AUTH_GITHUB_ENABLED=true \
    -e APICORE_AUTH_GITHUB_CLIENT=f121e8a63a27988dcb38 \
    -e APICORE_AUTH_GITHUB_SECRET=f618b4ba30a79718a3b4194223a08c16afbc2638 \
    -e APICORE_DATABASE_LOGGING=1 \
    -e APICORE_SERVER_MAX_UPLOAD_FILESIZE=500 \
    -p 8080:8080 \
    apicore
