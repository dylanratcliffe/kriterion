#!/usr/bin/env bash

docker build -t kriterion-base .
docker build -t kriterion-worker docker/worker
docker build -t kriterion-api docker/api
