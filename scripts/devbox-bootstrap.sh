#!/usr/bin/env bash
# scripts/devbox-bootstrap.sh — ce que le conteneur ajoute à l'image devbox.
#
# L'image `ghcr.io/busymoood/dotfiles-docker` fournit zsh/tmux/nvim/opencode,
# socat + `devbox-agent-relay` (agent SSH), et clone les configs (dotfiles +
# LazyVim) via son `onstart`. Ce script ne gère que le surplus **propre au
# projet** : module Python Playwright + Chromium, Node 22.
#
# Points d'entrée :
#   create   .devcontainer/devcontainer.json → postCreateCommand (1×/création)
#   start    .devcontainer/devcontainer.json → postStartCommand  (chaque boot)
#   up       docker-compose.yml → command (démarrage manuel, puis sleep)
#   doctor   diagnostic (délègue à devbox-agent-relay + état du projet)
#
# Idempotent : rejouable à chaque démarrage.
set -euo pipefail

VOLUME="${HOME}/.local"
BROWSERS="${PLAYWRIGHT_BROWSERS_PATH:-${VOLUME}/ms-playwright}"

log()  { printf '\033[1;34m[devbox-projet]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[devbox-projet][attention]\033[0m %s\n' "$*" >&2; }

apt_install() {
  sudo apt-get update -qq && sudo apt-get install -y -qq --no-install-recommends "$@"
}

# --- provisioning (uniquement si nécessaire) --------------------------------
ensure_volume_writable() {
  mkdir -p "$VOLUME"
  [[ -w "$VOLUME" ]] && return 0
  log "Volume ${VOLUME} non inscriptible — correction des permissions…"
  sudo chown -R "$(id -u):$(id -g)" "$VOLUME" 2>/dev/null \
    || warn "chown impossible sur ${VOLUME} (pip --user / Chromium échoueront)."
}

ensure_pip() {
  command -v pip3 >/dev/null 2>&1 && return 0
  log "Installation de python3-pip…"
  apt_install python3-pip
}

ensure_playwright_module() {
  python3 -c 'import playwright' 2>/dev/null && return 0
  log "Installation du module Python playwright…"
  # Ubuntu 24.04 est « externally managed » (PEP 668) : pip refuse une install
  # sans --break-system-packages. L'installation reste --user (volume), elle
  # n'écrit rien dans les paquets système.
  python3 -m pip install --user --quiet playwright >/dev/null 2>&1 \
    || python3 -m pip install --user --quiet --break-system-packages playwright
}

ensure_chromium() {
  compgen -G "${BROWSERS}/chromium-*/chrome-linux*/chrome" >/dev/null && return 0
  log "Téléchargement de Chromium dans ${BROWSERS}…"
  python3 -m playwright install chromium
}

ensure_chromium_deps() {
  # Marqueur dans $HOME (couche conteneur), PAS dans le volume : les paquets
  # apt installés par install-deps meurent avec le conteneur, alors que le
  # volume survit → un marqueur dans ~/.local mentirait après recréation.
  local marker="${HOME}/.cache/devbox-playwright-deps-ok"
  [[ -f "$marker" ]] && return 0
  log "Installation des dépendances système de Chromium…"
  sudo -E python3 -m playwright install-deps chromium
  mkdir -p "$(dirname "$marker")" && touch "$marker"
}

link_toolchain() {
  local dir="$1" bin
  for bin in node npm npx; do
    sudo ln -sf "${dir}/bin/${bin}" "/usr/local/bin/${bin}"
  done
}

# Node 22 : fourni par la feature `node` en dev container, absent de l'image.
# En mode compose, on l'installe dans le volume (une seule fois) pour que
# `npm run dev|build|lint` fonctionne. Le site n'a pas besoin de `gh` ni de la
# CLI Docker (réservés au dev container) — voir README.
ensure_node() {
  command -v node >/dev/null 2>&1 && return 0

  local dir="${VOLUME}/toolchain/node"
  if [[ -x "${dir}/bin/node" ]]; then
    link_toolchain "$dir"
    return 0
  fi

  local arch ver tmp
  case "$(uname -m)" in
    aarch64 | arm64) arch="arm64" ;;
    x86_64) arch="x64" ;;
    *) warn "Architecture inconnue ($(uname -m)) — Node non installé."; return 1 ;;
  esac

  log "Installation de Node 22 dans ${dir}…"
  ver="$(curl -fsSL --retry 3 https://nodejs.org/dist/index.json \
    | jq -r '[.[] | select(.version | startswith("v22."))][0].version')" || true
  if [[ -z "${ver:-}" || "$ver" == "null" ]]; then
    warn "Version Node 22 introuvable — ‘npm run dev’ indisponible en mode compose."
    return 1
  fi

  tmp="$(mktemp -d)"
  curl -fsSL --retry 3 -o "${tmp}/node.tar.gz" \
    "https://nodejs.org/dist/${ver}/node-${ver}-linux-${arch}.tar.gz"
  mkdir -p "$dir"
  tar -xzf "${tmp}/node.tar.gz" -C "$dir" --strip-components=1
  rm -rf "$tmp"
  link_toolchain "$dir"
  log "Node ${ver} installé (${dir})"
}

create() {
  ensure_volume_writable
  ensure_pip
  ensure_playwright_module
  ensure_chromium
  ensure_chromium_deps
  ensure_node || true
  log "Provisionnement terminé (playwright, chromium, node)."
}

# --- démarrage ---------------------------------------------------------------
# L'agent SSH est géré par l'image : `devbox-agent-relay` (montage direct sur
# Docker natif, relais TCP sur Docker Desktop, rattrapage si Bitwarden est
# verrouillé). Voir `devbox-agent-relay doctor`.
start() {
  devbox-agent-relay start || true
  # `onstart` (image) : attend le socket, vérifie l'agent, clone/pull dotfiles
  # + config NeoVim, corrige les permissions du volume.
  onstart --no-shell
}

doctor() {
  devbox-agent-relay doctor
  echo "== projet"
  printf '  %-12s %s\n' "node" "$(node --version 2>/dev/null || echo MANQUANT)"
  printf '  %-12s %s\n' "playwright" "$(python3 -c 'import playwright; print("OK")' 2>/dev/null || echo MANQUANT)"
  printf '  %-12s %s\n' "chromium" "$(ls -d "${BROWSERS}"/chromium-* 2>/dev/null | head -1 || echo MANQUANT)"
}

case "${1:-start}" in
  create) create ;;
  start) start ;;
  doctor) doctor ;;
  up)
    create
    start
    log "Conteneur prêt — entrer avec : docker compose exec dev zsh"
    exec sleep infinity
    ;;
  *)
    echo "usage: $0 [create|start|up|doctor]" >&2
    exit 2
    ;;
esac
