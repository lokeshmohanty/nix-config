#!/usr/bin/env bash
set -Eeuo pipefail

TARGET_USER="$(id -un)"
readonly TARGET_USER
readonly TARGET_HOME="${HOME}"
readonly REPO_DIR="${TARGET_HOME}/.nix"
readonly REPO_URL="https://github.com/lokeshmohanty/nix.git"
readonly REPO_BRANCH="main"
readonly FLAKE_TARGET="lokesh@server"
readonly USER_BIN="${TARGET_HOME}/.local/bin"
readonly USER_SHARE="${TARGET_HOME}/.local/share/lokesh-config"

installer_file=""
install_mode=""
apt_updated=false
backup_root=""
update_tools=false
select_packages=false
declare -A selected_group=()
declare -A selected_tool=()

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
Usage: install.sh [--with-nix | --without-nix] [--select-packages] [--update-tools]

Install this repository's Ubuntu configuration for the current login user.

  --with-nix     Install/reuse Nix and apply the Home Manager server profile.
  --without-nix  Install Ubuntu/system and upstream user tools, then link configs.
  --update-tools Re-run upstream installers even when their user-local command exists.
  --select-packages Show the package checklist in APT mode (defaults to all selected).
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
      --update-tools) update_tools=true ;;
      --select-packages) select_packages=true ;;
      -h|--help)
        usage
        exit 0
        ;;
      *) die "unknown argument: $1 (use --help)" ;;
    esac
    shift
  done
}

choose_package_groups() {
  local -a names=(
    "Ubuntu system packages"
    "Python tools (uv, jc, pre-commit, vdirsyncer)"
    "Shell tools (zoxide, just, direnv, fzf)"
    "Media/download tools (yt-dlp)"
    "Neovim"
    "Node.js tools (Gemini CLI, pi)"
    "AI CLIs (Qwen, Codex, Claude, Antigravity)"
    "Repository configuration links"
  )
  local i answer
  selected_tool[vdirsyncer]=0
  for i in "${!names[@]}"; do selected_group["${i}"]=1; done
  [[ -r /dev/tty && -w /dev/tty ]] || return
  printf '\nSelect packages to install (comma-separated numbers; Enter keeps all):\n' >/dev/tty
  for i in "${!names[@]}"; do printf '  [%s] %d) %s\n' x "$((i + 1))" "${names[i]}" >/dev/tty; done
  printf 'Numbers to deselect: ' >/dev/tty
  IFS= read -r answer </dev/tty || die "could not read package selection"
  [[ -z "${answer}" ]] && return
  for i in "${!names[@]}"; do selected_group["${i}"]=1; done
  local item
  IFS=',' read -ra items <<<"${answer}"
  for item in "${items[@]}"; do
    [[ "${item}" =~ ^[1-8]$ ]] || die "invalid package selection: ${item}"
    selected_group[$((item - 1))]=0
  done
  group_selected 1 && {
    selected_tool[vdirsyncer]=0
    choose_subgroup "Python tools" "jc,pre-commit,vdirsyncer" "jc|pre-commit|vdirsyncer"
  }
  group_selected 5 && {
    choose_subgroup "Node.js tools" "gemini,pi" "Gemini CLI|pi coding agent"
  }
}

group_selected() { [[ "${selected_group[$1]:-0}" == 1 ]]; }

choose_subgroup() {
  local title="$1" keys_csv="$2" labels_csv="$3" key label i answer
  local -a keys labels items
  IFS=',' read -ra keys <<<"${keys_csv}"
  IFS='|' read -ra labels <<<"${labels_csv}"
  for i in "${!keys[@]}"; do
    [[ -v "selected_tool[${keys[i]}]" ]] || selected_tool["${keys[i]}"]=1
  done
  printf '\n%s (comma-separated numbers to deselect; Enter keeps defaults):\n' "${title}" >/dev/tty
  for i in "${!keys[@]}"; do
    printf '  [%s] %d) %s\n' "${selected_tool[${keys[i]}]:-0}" "$((i + 1))" "${labels[i]}" >/dev/tty
  done
  printf 'Numbers to deselect: ' >/dev/tty
  IFS= read -r answer </dev/tty || die "could not read package selection"
  [[ -z "${answer}" ]] && return
  IFS=',' read -ra items <<<"${answer}"
  for key in "${items[@]}"; do
    [[ "${key}" =~ ^[1-9][0-9]*$ && key -le ${#keys[@]} ]] \
      || die "invalid selection in ${title}: ${key}"
    selected_tool["${keys[$((key - 1))]}"]=0
  done
}

download_installer() {
  local name="$1"
  local url="$2"

  installer_file="$(mktemp)"
  log "Downloading the official ${name} installer"
  curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location \
    --retry 3 --connect-timeout 15 "${url}" --output "${installer_file}"
  [[ -s "${installer_file}" ]] || die "the ${name} installer download was empty"
}

finish_installer() {
  rm -f -- "${installer_file}"
  installer_file=""
}

managed_command_exists() {
  [[ -x "${USER_BIN}/$1" ]]
}

should_install_managed_command() {
  [[ "${update_tools}" == true ]] || ! managed_command_exists "$1"
}

ensure_user_path() {
  local path_line='export PATH="$HOME/.local/bin:$PATH"'
  local profile="${TARGET_HOME}/.profile"

  mkdir -p -- "${USER_BIN}" "${USER_SHARE}"
  export PATH="${USER_BIN}:${PATH}"
  if [[ ! -f "${profile}" ]] || ! grep -Fqx "${path_line}" "${profile}"; then
    log "Adding ~/.local/bin to the login PATH"
    printf '\n# User-local tools installed by ~/.nix/scripts/install.sh\n%s\n' \
      "${path_line}" >>"${profile}"
  fi
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

ubuntu_universe_enabled() {
  grep -RqsE \
    '^[[:space:]]*(deb .*([[:space:]])universe([[:space:]]|$)|Components:.*([[:space:]])universe([[:space:]]|$))' \
    /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null
}

install_apt_packages() {
  local -a required_packages=(
    ca-certificates
    curl
    git
    python3
    xz-utils
  )
  local -a requested_packages=(
    ffmpeg
    file
    fish
    gnupg
    isync
    jq
    libimage-exiftool-perl
    make
    notmuch
    pandoc
    pass
    poppler-utils
    postgresql-client
    python3-venv
    sqlite3
    tmux
    xdg-user-dirs
    xdg-utils
    zathura
    zathura-pdf-poppler
    zsh
  )
  local -a available_packages=()
  local -a missing_required=()
  local -a skipped_packages=()
  local package

  if ! group_selected 0; then
    requested_packages=()
    log "Skipping optional Ubuntu system packages"
  fi

  if ! ubuntu_universe_enabled; then
    update_apt
    if ! have add-apt-repository; then
      sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        software-properties-common
    fi
    log "Enabling the Ubuntu universe repository"
    sudo add-apt-repository --yes universe
    apt_updated=false
  else
    log "Ubuntu universe repository is already enabled"
  fi
  update_apt

  for package in "${required_packages[@]}"; do
    if ! apt-cache show "${package}" >/dev/null 2>&1; then
      missing_required+=("${package}")
    fi
  done
  (( ${#missing_required[@]} == 0 )) \
    || die "bootstrap Ubuntu packages are unavailable: ${missing_required[*]}"

  for package in "${requested_packages[@]}"; do
    if apt-cache show "${package}" >/dev/null 2>&1; then
      available_packages+=("${package}")
    else
      skipped_packages+=("${package}")
    fi
  done

  log "Installing OS-integrated packages available from this Ubuntu release"
  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    "${required_packages[@]}" "${available_packages[@]}"

  if (( ${#skipped_packages[@]} > 0 )); then
    warn "skipped packages unavailable for this Ubuntu release/architecture: ${skipped_packages[*]}"
  fi
}

install_uv_tools() {
  group_selected 1 || return
  local command package
  local -a python_tools=(
    "jc|jc"
    "pre-commit|pre-commit"
    "vdirsyncer|vdirsyncer"
  )

  if should_install_managed_command uv; then
    download_installer uv https://astral.sh/uv/install.sh
    UV_NO_MODIFY_PATH=1 UV_INSTALL_DIR="${USER_BIN}" sh "${installer_file}"
    finish_installer
  fi
  managed_command_exists uv || die "uv installed but ${USER_BIN}/uv is unavailable"

  for package in "${python_tools[@]}"; do
    IFS='|' read -r command package <<<"${package}"
    [[ "${selected_tool[${command}]:-1}" == 1 ]] || continue
    if ! managed_command_exists "${command}"; then
      log "Installing ${package} with uv from its official Python package"
      "${USER_BIN}/uv" tool install "${package}"
    elif [[ "${update_tools}" == true ]]; then
      log "Updating ${package} with uv"
      "${USER_BIN}/uv" tool upgrade "${package}"
    fi
  done
}

install_zoxide() {
  group_selected 2 || return
  should_install_managed_command zoxide || return
  download_installer zoxide \
    https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh
  sh "${installer_file}" --bin-dir "${USER_BIN}"
  finish_installer
  managed_command_exists zoxide || die "zoxide installed but ${USER_BIN}/zoxide is unavailable"
}

install_just() {
  group_selected 2 || return
  should_install_managed_command just || return
  download_installer just https://just.systems/install.sh
  sh "${installer_file}" --to "${USER_BIN}"
  finish_installer
  managed_command_exists just || die "just installed but ${USER_BIN}/just is unavailable"
}

install_direnv() {
  group_selected 2 || return
  should_install_managed_command direnv || return
  download_installer direnv https://direnv.net/install.sh
  bin_path="${USER_BIN}" bash "${installer_file}"
  finish_installer
  managed_command_exists direnv || die "direnv installed but ${USER_BIN}/direnv is unavailable"
}

install_fzf() {
  group_selected 2 || return
  local fzf_dir="${USER_SHARE}/fzf"

  if [[ ! -d "${fzf_dir}/.git" ]]; then
    log "Cloning the official fzf repository"
    git clone --depth 1 https://github.com/junegunn/fzf.git "${fzf_dir}"
  elif [[ "${update_tools}" == true ]]; then
    log "Updating fzf from its official repository"
    git -C "${fzf_dir}" pull --ff-only
  elif managed_command_exists fzf; then
    return
  fi

  "${fzf_dir}/install" --bin --no-update-rc
  ln -sfnT -- "${fzf_dir}/bin/fzf" "${USER_BIN}/fzf"
  managed_command_exists fzf || die "fzf installed but ${USER_BIN}/fzf is unavailable"
}

install_yt_dlp() {
  group_selected 3 || return
  local asset_url

  should_install_managed_command yt-dlp || return
  case "$(uname -m)" in
    x86_64)
      asset_url=https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux
      ;;
    aarch64|arm64)
      asset_url=https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux_aarch64
      ;;
    *)
      warn "yt-dlp has no configured standalone asset for $(uname -m); skipping"
      return
      ;;
  esac

  installer_file="$(mktemp)"
  log "Downloading the official yt-dlp standalone binary"
  curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location \
    --retry 3 --connect-timeout 15 "${asset_url}" --output "${installer_file}"
  install -m 0755 "${installer_file}" "${USER_BIN}/yt-dlp"
  finish_installer
}

install_node() {
  group_selected 5 || return
  local node_arch node_filename node_version node_root node_target node_tmp

  case "$(uname -m)" in
    x86_64) node_arch=x64 ;;
    aarch64|arm64) node_arch=arm64 ;;
    *) die "the official Node.js binary install is unsupported on $(uname -m)" ;;
  esac

  node_tmp="$(mktemp -d)"
  log "Resolving the latest official Node.js 22 release"
  curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location \
    --retry 3 --connect-timeout 15 \
    https://nodejs.org/dist/latest-v22.x/SHASUMS256.txt \
    --output "${node_tmp}/SHASUMS256.txt"
  node_filename="$(
    awk -v suffix="linux-${node_arch}.tar.xz" '$2 ~ suffix "$" { print $2; exit }' \
      "${node_tmp}/SHASUMS256.txt"
  )"
  [[ -n "${node_filename}" ]] || die "could not resolve a Node.js 22 ${node_arch} archive"
  node_version="${node_filename#node-}"
  node_version="${node_version%-linux-${node_arch}.tar.xz}"
  node_root="${USER_SHARE}/node"
  node_target="${node_root}/${node_version}"

  if [[ ! -x "${node_target}/bin/node" ]]; then
    log "Downloading official Node.js ${node_version}"
    curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location \
      --retry 3 --connect-timeout 15 \
      "https://nodejs.org/dist/latest-v22.x/${node_filename}" \
      --output "${node_tmp}/${node_filename}"
    grep -F " ${node_filename}" "${node_tmp}/SHASUMS256.txt" \
      >"${node_tmp}/node.sha256"
    (cd "${node_tmp}" && sha256sum --check node.sha256)
    tar -xJf "${node_tmp}/${node_filename}" -C "${node_tmp}"
    mkdir -p -- "${node_root}"
    mv -- "${node_tmp}/${node_filename%.tar.xz}" "${node_target}"
  fi

  ln -sfnT -- "${node_target}/bin/node" "${USER_BIN}/node"
  ln -sfnT -- "${node_target}/bin/npm" "${USER_BIN}/npm"
  ln -sfnT -- "${node_target}/bin/npx" "${USER_BIN}/npx"
  ln -sfnT -- "${node_target}/bin/corepack" "${USER_BIN}/corepack"
  rm -rf -- "${node_tmp}"
  log "Using $(${USER_BIN}/node --version) from the official Node.js release"
}

install_node_clis() {
  group_selected 5 || return
  local -a npm_tools=(
    "gemini|@google/gemini-cli@latest"
    "pi|@earendil-works/pi-coding-agent@latest"
  )
  local command package

  for package in "${npm_tools[@]}"; do
    IFS='|' read -r command package <<<"${package}"
    [[ "${selected_tool[${command}]:-1}" == 1 ]] || continue
    if should_install_managed_command "${command}"; then
      log "Installing ${package} from its official npm package"
      "${USER_BIN}/npm" install --global --prefix "${TARGET_HOME}/.local" "${package}"
    fi
  done
}

install_neovim() {
  group_selected 4 || return
  local archive_name archive_url neovim_arch neovim_tmp release_tag target

  should_install_managed_command nvim || return
  case "$(uname -m)" in
    x86_64) neovim_arch=x86_64 ;;
    aarch64|arm64) neovim_arch=arm64 ;;
    *)
      warn "Neovim has no configured official archive for $(uname -m); skipping"
      return
      ;;
  esac

  archive_name="nvim-linux-${neovim_arch}.tar.gz"
  archive_url="https://github.com/neovim/neovim/releases/latest/download/${archive_name}"
  neovim_tmp="$(mktemp -d)"
  log "Resolving the latest official Neovim release"
  curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location \
    --retry 3 --connect-timeout 15 \
    https://api.github.com/repos/neovim/neovim/releases/latest \
    --output "${neovim_tmp}/release.json"
  release_tag="$(
    python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["tag_name"])' \
      "${neovim_tmp}/release.json"
  )"
  [[ "${release_tag}" =~ ^v[0-9] ]] || die "could not resolve the latest Neovim version"
  target="${USER_SHARE}/neovim/${release_tag}"

  if [[ ! -x "${target}/bin/nvim" ]]; then
    log "Downloading official Neovim ${release_tag}"
    curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location \
      --retry 3 --connect-timeout 15 "${archive_url}" \
      --output "${neovim_tmp}/${archive_name}"
    curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location \
      --retry 3 --connect-timeout 15 \
      https://github.com/neovim/neovim/releases/latest/download/shasum.txt \
      --output "${neovim_tmp}/shasum.txt"
    grep -F " ${archive_name}" "${neovim_tmp}/shasum.txt" \
      >"${neovim_tmp}/neovim.sha256"
    (cd "${neovim_tmp}" && sha256sum --check neovim.sha256)
    tar -xzf "${neovim_tmp}/${archive_name}" -C "${neovim_tmp}"
    mkdir -p -- "$(dirname "${target}")"
    mv -- "${neovim_tmp}/nvim-linux-${neovim_arch}" "${target}"
  fi

  ln -sfnT -- "${target}/bin/nvim" "${USER_BIN}/nvim"
  rm -rf -- "${neovim_tmp}"
}

install_native_ai_tools() {
  group_selected 6 || return
  if should_install_managed_command qwen; then
    download_installer "Qwen Code" \
      https://qwen-code-assets.oss-cn-hangzhou.aliyuncs.com/installation/install-qwen-standalone.sh
    bash "${installer_file}"
    finish_installer
  fi

  if should_install_managed_command codex; then
    download_installer "OpenAI Codex" https://chatgpt.com/codex/install.sh
    sh "${installer_file}"
    finish_installer
  fi

  if should_install_managed_command claude; then
    download_installer "Claude Code" https://claude.ai/install.sh
    bash "${installer_file}"
    finish_installer
  fi

  if should_install_managed_command agy; then
    download_installer "Google Antigravity CLI" \
      https://antigravity.google/cli/install.sh
    bash "${installer_file}" --skip-aliases --skip-path
    finish_installer
  fi
}

install_upstream_tools() {
  ensure_user_path
  install_uv_tools
  install_zoxide
  install_just
  install_direnv
  install_fzf
  install_yt_dlp
  install_neovim
  install_node
  install_node_clis
  install_native_ai_tools
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
  group_selected 7 || { log "Skipping repository configuration links"; return; }
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

  local nvim_version=""
  if have nvim; then
    nvim_version="$(nvim --version | sed -n '1s/^NVIM v//p')"
  fi
  if [[ -n "${nvim_version}" ]] && dpkg --compare-versions "${nvim_version}" ge 0.7; then
    link_managed_path "${REPO_DIR}/pkgs/nvim" "${TARGET_HOME}/.config/nvim"
  else
    warn "Neovim ${nvim_version:-unavailable} is too old for this config; leaving ~/.config/nvim unchanged"
  fi

  if [[ -x /usr/bin/fdfind ]]; then
    link_managed_path /usr/bin/fdfind "${TARGET_HOME}/.local/bin/fd"
  fi
  warn "APT mode cannot reproduce the wrapped Neovim plugin/LSP bundle or Home Manager-generated shell settings"
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
  if [[ "${install_mode}" == "apt" ]]; then
    choose_package_groups
  fi

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
    install_upstream_tools
    setup_config_files
  fi

  log "Ubuntu home configuration installed successfully"
  log "Log out and back in to make all session environment changes visible"
}

main "$@"
