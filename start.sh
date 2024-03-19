#!/usr/bin/env bash

cd /home/ubuntu/app/restdb

./gradlew bootRun

sudo docker compose -f docker-compose.yml up -d