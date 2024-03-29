#!/bin/bash
docker stop fms-docker
docker remove fms-docker
bash ./build.sh