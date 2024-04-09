#!/bin/bash
source ./init.sh

# Build docker for version ubuntu and version filemaker
echo "Trying to build: fmsdocker:ubuntu22.04-fms$VERSION"
docker image build -t fmsdocker:ubuntu22.04-fms$VERSION ./ --build-arg VERSION=$VERSION
bash ./run.sh