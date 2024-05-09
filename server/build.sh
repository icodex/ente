#!/bin/sh

docker buildx build -f Dockerfile -t icodex/ente-server --platform=linux/arm64,linux/amd64 . --push
