#!/usr/bin/env bash
set -euo pipefail

APP_DIR=${APP_DIR:-/opt/sub2api}
COMPOSE_FILES=(-f docker-compose.local.yml -f docker-compose.override.yml)

cd "$APP_DIR"

if [ -n "$(git status --porcelain)" ]; then
  echo "Local changes detected in $APP_DIR; commit or stash them before updating." >&2
  git status --short >&2
  exit 1
fi

git fetch origin main
git checkout main
git pull --ff-only origin main

cd "$APP_DIR/deploy"
SUB2API_COMMIT=$(git -C "$APP_DIR" rev-parse --short HEAD)
export SUB2API_COMMIT

docker compose "${COMPOSE_FILES[@]}" pull postgres redis
docker compose "${COMPOSE_FILES[@]}" build sub2api
docker compose "${COMPOSE_FILES[@]}" up -d
docker compose "${COMPOSE_FILES[@]}" ps
