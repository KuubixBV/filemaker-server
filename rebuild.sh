#!/bin/bash
source ./init.sh

# Stop and remove docker - build aftwards
bash ./down.sh
bash ./remove.sh
bash ./build.sh