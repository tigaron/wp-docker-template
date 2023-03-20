#!/usr/bin/env bash

if [ "$(docker ps -q -f name=wordpress)" ]; then
    docker-compose pull wordpress
    docker-compose stop wordpress
    docker-compose up -d --no-deps --build wordpress
else
    docker-compose up -d
fi
