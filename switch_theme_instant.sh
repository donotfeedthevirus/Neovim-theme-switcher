#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $(basename "$0") <theme-name>"
  exit 1
fi

theme="$1"

# Map your human-friendly slug -> actual :colorscheme name
declare -A themes=(
  ["everforest"]="everforest"
  ["flexoki"]="flexoki-light"
  ["kanagawa"]="kanagawa"
  ["matte-black"]="matteblack"
  ["osaka-jade"]="bamboo"
  ["ristretto"]="monokai-pro"
  ["artzen"]="darkrose"
  ["pink-blood"]="pixel"
)

# Per-theme background preference
# Use "light" or "dark" (themes that ignore it won’t break)
declare -A bg=(
  ["everforest"]="dark"
  ["flexoki"]="light"
  ["kanagawa"]="dark"
  ["matte-black"]="dark"
  ["osaka-jade"]="dark"
  ["ristretto"]="dark"
  ["artzen"]="dark"
  ["pink-blood"]="dark"
)

if [[ -z "${themes[$theme]:-}" ]]; then
  echo "theme does not exist"
  exit 1
fi

cs="${themes[$theme]}"
b="${bg[$theme]:-dark}"  # sane default

# Find all running headless UI sockets; skip if none
shopt -s nullglob
files=()
if [[ -n ${XDG_RUNTIME_DIR-} && -d ${XDG_RUNTIME_DIR-} ]]; then
  files=("${XDG_RUNTIME_DIR}"/nvim.*)
else
  files=(/run/user/*/nvim.*)
fi
shopt -u nullglob

if ((${#files[@]} == 0)); then
  echo "No Neovim servers found — not changing theme."
  exit 0
fi

for file in "${files[@]}"; do
  nvim --server "$file" --remote-expr "execute('colorscheme ${cs}')"
done

echo "✅ Applied ${theme} (${cs}) with ${b} background to ${#files[@]} instance(s)."
