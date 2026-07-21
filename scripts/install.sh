#!/usr/bin/env bash
set -Eeuo pipefail

TARGET_USER="$(id -un)"
readonly TARGET_USER
readonly TARGET_HOME="${HOME}"
readonly REPO_DIR="${TARGET_HOME}/.nix"
readonly REPO_URL="https://github.com/lokeshmohanty/nix.git"
readonly REPO_BRANCH="main"
readonly FLAKE_TARGET="lokesh@server"

installer_file=""
install_mode=""
apt_updated=false
backup_root=""

cleanup() {
  if [[ -n "${installer_file}" && -f "${installer_file}" ]]; then
    rm -f -- "${installer_file}"
  fi
}
trap cleanup EXIT

log() {
  printf '[install] %s\n' "$*"
}

warn() {
  printf '[install] warning: %s\n' "$*" >&2
}

die() {
  printf '[install] error: %s\n' "$*" >&2
  exit 1
}

have() {
  command -v "$1" >/dev/null 2>&1
}

usage() {
  cat <<'EOF'
Usage: install.sh [--with-nix | --without-nix]

Install this repository's Ubuntu configuration for the current login user.

  --with-nix     Install/reuse Nix and apply the Home Manager server profile.
  --without-nix  Install Ubuntu packages with APT and link configs directly.
  -h, --help     Show this help.

With no mode flag, the installer asks whether Nix is required.
EOF
}

set_install_mode() {
  local requested_mode="$1"
  [[ -z "${install_mode}" || "${install_mode}" == "${requested_mode}" ]] \
    || die "choose only one of --with-nix or --without-nix"
  install_mode="${requested_mode}"
}

parse_args() {
  while (( $# > 0 )); do
    case "$1" in
      --with-nix) set_install_mode nix ;;
      --without-nix) set_install_mode apt ;;
      -h|--help)
        usage
        exit 0
        ;;
      *) die "unknown argument: $1 (use --help)" ;;
    esac
    shift
  done
}

choose_install_mode() {
  [[ -z "${install_mode}" ]] || return
  [[ -r /dev/tty && -w /dev/tty ]] \
    || die "no interactive terminal; use --with-nix or --without-nix"

  local answer
  while true; do
    printf 'Is Nix required on this system? [y/N] ' >/dev/tty
    IFS= read -r answer </dev/tty || die "could not read installation choice"
    case "${answer}" in
      y|Y|yes|YES|Yes)
        install_mode="nix"
        return
        ;;
      ''|n|N|no|NO|No)
        install_mode="apt"
        return
        ;;
      *) printf 'Please answer yes or no.\n' >/dev/tty ;;
    esac
  done
}

load_nix_environment() {
  if [[ -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    # shellcheck disable=SC1091
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  elif [[ -r "${TARGET_HOME}/.nix-profile/etc/profile.d/nix.sh" ]]; then
    # shellcheck disable=SC1091
    source "${TARGET_HOME}/.nix-profile/etc/profile.d/nix.sh"
  fi
}

require_supported_host() {
  [[ -r /etc/os-release ]] || die "cannot identify this operating system"
  # shellcheck disable=SC1091
  source /etc/os-release

  [[ "${ID:-}" == "ubuntu" ]] || die "only Ubuntu is supported for now (found ${ID:-unknown})"
  (( EUID != 0 )) || die "run this installer as the target login user, not as root"

  local current_user passwd_home
  current_user="$(id -un)"
  passwd_home="$(getent passwd "${current_user}" | cut -d: -f6)"

  [[ "${current_user}" == "${TARGET_USER}" ]] || die "could not resolve the login user"
  [[ -n "${passwd_home}" && "${TARGET_HOME}" == "${passwd_home}" ]] \
    || die "HOME (${TARGET_HOME}) does not match ${TARGET_USER}'s passwd home (${passwd_home:-missing})"
}

require_nix_mode_host() {
  [[ "$(uname -m)" == "x86_64" ]] \
    || die "the Nix/Home Manager path currently supports only x86_64 Ubuntu"
}

update_apt() {
  [[ "${apt_updated}" == true ]] && return
  have sudo || die "sudo is required to install Ubuntu packages"
  sudo -v
  log "Refreshing Ubuntu package metadata"
  sudo env DEBIAN_FRONTEND=noninteractive apt-get update
  apt_updated=true
}

ensure_bootstrap_dependencies() {
  if have curl && have git; then
    return
  fi

  log "Installing Ubuntu bootstrap dependencies"
  update_apt
  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates curl git
}

install_nix() {
  load_nix_environment
  if have nix; then
    log "Using existing $(nix --version)"
    return
  fi

  if [[ -e /nix/receipt.json || -d /nix/store ]]; then
    die "found a partial or inactive Nix installation under /nix; repair or remove it before retrying"
  fi
  [[ -d /run/systemd/system ]] \
    || die "installing Nix currently requires an Ubuntu system booted with systemd"

  installer_file="$(mktemp)"
  log "Downloading the Determinate Nix installer"
  curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location \
    https://install.determinate.systems/nix \
    --output "${installer_file}"

  log "Installing Nix"
  sh "${installer_file}" install linux --no-confirm --init systemd
  load_nix_environment
  have nix || die "Nix installed but is not available in this shell"
  log "Installed $(nix --version)"
}

validate_origin() {
  local origin
  origin="$(git -C "${REPO_DIR}" remote get-url origin)"
  case "${origin}" in
    "${REPO_URL}"|"https://github.com/lokeshmohanty/nix"|"git@github.com:lokeshmohanty/nix.git") ;;
    *) die "${REPO_DIR} has an unexpected origin: ${origin}" ;;
  esac
}

sync_repository() {
  if [[ ! -e "${REPO_DIR}" ]]; then
    log "Cloning configuration into ${REPO_DIR}"
    git clone --branch "${REPO_BRANCH}" --single-branch "${REPO_URL}" "${REPO_DIR}"
    return
  fi

  [[ -d "${REPO_DIR}/.git" ]] || die "${REPO_DIR} exists but is not a Git checkout"
  validate_origin
  [[ "$(git -C "${REPO_DIR}" branch --show-current)" == "${REPO_BRANCH}" ]] \
    || die "${REPO_DIR} must be on branch ${REPO_BRANCH}"
  [[ -z "$(git -C "${REPO_DIR}" status --porcelain)" ]] \
    || die "${REPO_DIR} has local changes; commit or remove them before retrying"

  log "Fast-forwarding ${REPO_DIR}"
  git -C "${REPO_DIR}" fetch --prune origin "${REPO_BRANCH}"
  git -C "${REPO_DIR}" merge --ff-only FETCH_HEAD
}

install_apt_packages() {
  local -a core_packages=(
    ca-certificates
    curl
    fd-find
    ffmpeg
    fish
    fzf
    gh
    git
    gnupg
    golang-go
    jc
    libimage-exiftool-perl
    make
    neovim
    nodejs
    npm
    pandoc
    pass
    postgresql-client
    pre-commit
    python3
    rclone
    ripgrep
    sqlite3
    tmux
    xdg-user-dirs
    xdg-utils
    yt-dlp
    zathura
    zathura-pdf-poppler
    zoxide
    zsh
  )
  local -a optional_packages=(
    direnv
    duf
    gdu
    git-delta
    gping
    hyperfine
    isync
    just
    lazygit
    notmuch
    sioyek
    tldr
    vdirsyncer
  )
  local -a available_optional=()
  local -a missing_core=()
  local -a skipped_optional=()
  local package

  update_apt
  if ! have add-apt-repository; then
    sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      software-properties-common
  fi
  log "Enabling the Ubuntu universe repository"
  sudo add-apt-repository --yes universe
  apt_updated=false
  update_apt

  for package in "${core_packages[@]}"; do
    if ! apt-cache show "${package}" >/dev/null 2>&1; then
      missing_core+=("${package}")
    fi
  done
  (( ${#missing_core[@]} == 0 )) \
    || die "required Ubuntu packages are unavailable: ${missing_core[*]}"

  for package in "${optional_packages[@]}"; do
    if apt-cache show "${package}" >/dev/null 2>&1; then
      available_optional+=("${package}")
    else
      skipped_optional+=("${package}")
    fi
  done

  log "Installing packages from Ubuntu repositories"
  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    "${core_packages[@]}" "${available_optional[@]}"

  if (( ${#skipped_optional[@]} > 0 )); then
    warn "not available for this Ubuntu release/architecture: ${skipped_optional[*]}"
  fi
}

backup_existing_path() {
  local target="$1"
  local relative_target backup_target

  [[ "${target}" == "${TARGET_HOME}"/* ]] \
    || die "refusing to back up a path outside ${TARGET_HOME}: ${target}"
  if [[ -z "${backup_root}" ]]; then
    backup_root="${TARGET_HOME}/.local/state/lokesh-config/backups/$(date -u +%Y%m%dT%H%M%SZ)-$$"
  fi

  relative_target="${target#"${TARGET_HOME}/"}"
  backup_target="${backup_root}/${relative_target}"
  mkdir -p -- "$(dirname "${backup_target}")"
  mv -- "${target}" "${backup_target}"
  warn "moved existing ${target} to ${backup_target}"
}

ensure_real_directory() {
  local directory="$1"
  if [[ -d "${directory}" && ! -L "${directory}" ]]; then
    return
  fi
  if [[ -e "${directory}" || -L "${directory}" ]]; then
    backup_existing_path "${directory}"
  fi
  mkdir -p -- "${directory}"
}

link_managed_path() {
  local source_path="$1"
  local target_path="$2"

  [[ -e "${source_path}" || -L "${source_path}" ]] \
    || die "managed source is missing: ${source_path}"
  mkdir -p -- "$(dirname "${target_path}")"

  if [[ -L "${target_path}" && "$(readlink "${target_path}")" == "${source_path}" ]]; then
    return
  fi
  if [[ -e "${target_path}" || -L "${target_path}" ]]; then
    backup_existing_path "${target_path}"
  fi
  ln -sfnT -- "${source_path}" "${target_path}"
}

setup_config_files() {
  local agents_dir="${REPO_DIR}/config/agentic-harness/agents"
  local -a runtime_directories=(
    "${TARGET_HOME}/.claude"
    "${TARGET_HOME}/.pi"
    "${TARGET_HOME}/.pi/agent"
    "${TARGET_HOME}/.codex"
    "${TARGET_HOME}/.gemini"
    "${TARGET_HOME}/.gemini/antigravity"
  )
  local -a managed_links=(
    "${REPO_DIR}/config/zk|${TARGET_HOME}/.config/zk"
    "${agents_dir}|${TARGET_HOME}/.agents"
    "${agents_dir}/AGENTS.md|${TARGET_HOME}/.claude/CLAUDE.md"
    "${agents_dir}/skills|${TARGET_HOME}/.claude/skills"
    "${REPO_DIR}/config/agentic-harness/claude/settings.json|${TARGET_HOME}/.claude/settings.json"
    "${REPO_DIR}/config/agentic-harness/claude/rules|${TARGET_HOME}/.claude/rules"
    "${REPO_DIR}/config/agentic-harness/pi/web-search.json|${TARGET_HOME}/.pi/web-search.json"
    "${REPO_DIR}/config/agentic-harness/pi/agent/settings.json|${TARGET_HOME}/.pi/agent/settings.json"
    "${REPO_DIR}/config/agentic-harness/pi/agent/models.json|${TARGET_HOME}/.pi/agent/models.json"
    "${agents_dir}/AGENTS.md|${TARGET_HOME}/.pi/agent/APPEND_SYSTEM.md"
    "${agents_dir}/skills|${TARGET_HOME}/.pi/agent/skills"
    "${agents_dir}/AGENTS.md|${TARGET_HOME}/.codex/AGENTS.md"
    "${agents_dir}/skills|${TARGET_HOME}/.codex/skills"
    "${agents_dir}/AGENTS.md|${TARGET_HOME}/.gemini/GEMINI.md"
    "${agents_dir}/AGENTS.md|${TARGET_HOME}/.gemini/antigravity/AGENTS.md"
    "${agents_dir}/skills|${TARGET_HOME}/.gemini/antigravity/skills"
    "${REPO_DIR}/config/agentic-harness/antigravity/mcp_config.json|${TARGET_HOME}/.gemini/antigravity/mcp_config.json"
    "${REPO_DIR}/scripts/add-vibe-skills|${TARGET_HOME}/.local/bin/add-vibe-skills"
    "${REPO_DIR}/scripts/email-md.sh|${TARGET_HOME}/.local/bin/email-md.sh"
    "${REPO_DIR}/scripts/fixes|${TARGET_HOME}/.local/bin/fixes"
    "${REPO_DIR}/scripts/install.sh|${TARGET_HOME}/.local/bin/install.sh"
    "${REPO_DIR}/scripts/oauthman|${TARGET_HOME}/.local/bin/oauthman"
    "${REPO_DIR}/scripts/setup-email.sh|${TARGET_HOME}/.local/bin/setup-email.sh"
    "${REPO_DIR}/config/agentic-harness/bin/docs-nudge|${TARGET_HOME}/.local/bin/docs-nudge"
    "${REPO_DIR}/config/agentic-harness/bin/harness-init|${TARGET_HOME}/.local/bin/harness-init"
    "${REPO_DIR}/config/agentic-harness/bin/harness-session-start|${TARGET_HOME}/.local/bin/harness-session-start"
  )
  local directory mapping source_path target_path

  log "Linking repository-managed configuration files"
  for directory in "${runtime_directories[@]}"; do
    ensure_real_directory "${directory}"
  done
  for mapping in "${managed_links[@]}"; do
    IFS='|' read -r source_path target_path <<<"${mapping}"
    link_managed_path "${source_path}" "${target_path}"
  done

  local nvim_version
  nvim_version="$(nvim --version | sed -n '1s/^NVIM v//p')"
  if [[ -n "${nvim_version}" ]] && dpkg --compare-versions "${nvim_version}" ge 0.7; then
    link_managed_path "${REPO_DIR}/pkgs/nvim" "${TARGET_HOME}/.config/nvim"
  else
    warn "Ubuntu Neovim ${nvim_version:-unknown} is too old for this config; leaving ~/.config/nvim unchanged"
  fi

  if [[ -x /usr/bin/fdfind ]]; then
    link_managed_path /usr/bin/fdfind "${TARGET_HOME}/.local/bin/fd"
  fi
  warn "APT mode cannot install Nix-only AI CLIs, the wrapped Neovim plugin/LSP bundle, or Home Manager-generated shell settings"
}

nix_cmd() {
  nix --extra-experimental-features 'nix-command flakes' --accept-flake-config "$@"
}

validate_home_configuration() {
  local configured_user configured_home
  configured_user="$(
    nix_cmd eval --impure --raw \
      "${REPO_DIR}#homeConfigurations.\"${FLAKE_TARGET}\".config.home.username"
  )"
  configured_home="$(
    nix_cmd eval --impure --raw \
      "${REPO_DIR}#homeConfigurations.\"${FLAKE_TARGET}\".config.home.homeDirectory"
  )"

  [[ "${configured_user}" == "${TARGET_USER}" ]] \
    || die "flake configures user ${configured_user}, expected ${TARGET_USER}"
  [[ "${configured_home}" == "${TARGET_HOME}" ]] \
    || die "flake configures home ${configured_home}, expected ${TARGET_HOME}"
}

apply_home_configuration() {
  local home_manager_package
  log "Building the Home Manager version pinned by flake.lock"
  home_manager_package="$(
    nix_cmd build --impure --no-link --print-out-paths \
      "${REPO_DIR}#homeConfigurations.\"${FLAKE_TARGET}\".config.programs.home-manager.package"
  )"

  [[ "${home_manager_package}" == /nix/store/* && -x "${home_manager_package}/bin/home-manager" ]] \
    || die "could not resolve the pinned Home Manager package"

  log "Applying ${FLAKE_TARGET}"
  "${home_manager_package}/bin/home-manager" \
    --option accept-flake-config true \
    --option experimental-features 'nix-command flakes' \
    --impure \
    switch \
    --flake "${REPO_DIR}#${FLAKE_TARGET}"
}

main() {
  parse_args "$@"
  require_supported_host
  choose_install_mode
  ensure_bootstrap_dependencies
  sync_repository

  if [[ "${install_mode}" == "nix" ]]; then
    require_nix_mode_host
    export LOKESH_CONFIG_USER="${TARGET_USER}"
    export LOKESH_CONFIG_HOME="${TARGET_HOME}"
    export LOKESH_CONFIG_DIR="${REPO_DIR}"
    install_nix
    validate_home_configuration
    apply_home_configuration
  else
    install_apt_packages
    setup_config_files
  fi

  log "Ubuntu home configuration installed successfully"
  log "Log out and back in to make all session environment changes visible"
}

main "$@"
