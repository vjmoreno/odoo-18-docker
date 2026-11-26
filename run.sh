#!/usr/bin/env bash

docker compose up -d --build

# Create logs folder if it does not exist
mkdir -p logs

sudo chmod -R 777 ./config ./addons ./logs

# Max size in bytes
MAX_SIZE=$((10 * 1024 * 1024)) 

# Verify and rotate log if its necessary
if [ -f logs/app.log ] && [ $(stat -c%s logs/app.log) -ge $MAX_SIZE ]; then
    mv logs/app.log logs/app-$(date +"%Y%m%d%H%M%S").log  # Rename file
    touch logs/app.log  # Create new log file
fi

docker compose logs -f >> logs/app.log &
echo "Odoo and PostgreSQL containers successfully created"
