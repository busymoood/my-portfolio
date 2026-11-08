#!/usr/bin/env bash
# scripts/devbox-up.sh — démarre le dev container avec les variables de .env.
#
# La CLI devcontainers ne lit pas les fichiers .env : elle substitue
# ${localEnv:VAR} depuis l'environnement du shell. Ce wrapper exporte .env
# puis lance `devcontainer up`, pour ne pas figer les valeurs dans
# `.devcontainer/devcontainer.json`.
#
# Usage : ./scripts/devbox-up.sh [args devcontainer up]
#   ex. : ./scripts/devbox-up.sh --remove-existing-container
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ ! -f .env ]]; then
  echo "ERREUR : .env absent — copier le modèle puis l'ajuster :" >&2
  echo "  cp .env.example .env" >&2
  exit 1
fi

# Charge .env (format shell : KEY=valeur, guillemets acceptés, # commentaires).
set -a
# shellcheck disable=SC1091
. ./.env
set +a

: "${DOTFILES_REPO:?DOTFILES_REPO manquant dans .env}"

exec devcontainer up --workspace-folder . "$@"
