#!/usr/bin/env bash

# Generate up-to-date test interface
#echo "👾 Generate up-to-date test interface"
#swift test --generate-linuxmain

# Build
echo "🤖 Build"
docker build -f ./docker/test/Dockerfile -t apicore .

# Run
echo "🏃‍♀️ Run"
docker run \
    -e APICORE_DATABASE_HOST=docker.for.mac.host.internal \
    -e APICORE_DATABASE_USER=boost \
    -e APICORE_DATABASE_DATABASE=boost-test \
    -e APICORE_DATABASE_LOGGING=1 \
    -e APICORE_SERVER_MAX_UPLOAD_FILESIZE=500 \
    -p 8080:8080 \
    apicore

