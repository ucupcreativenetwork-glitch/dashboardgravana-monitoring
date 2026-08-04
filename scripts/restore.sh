#!/usr/bin/env bash
# Restore from a backup archive produced by scripts/backup.sh
set -euo pipefail
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <backup-tar.gz>"
  exit 1
fi
ARCHIVE="$1"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

echo "[WARN] This will overwrite configuration. Ensure the stack is stopped."
read -r -p "Continue? [y/N] " ans
[[ "${ans}" =~ ^[Yy]$ ]] || exit 0

tar -xzf "${ARCHIVE}" -C "${ROOT_DIR}"
echo "[OK] Configuration restored. Restart the stack with: docker compose up -d"
echo "[INFO] Volume data restores (if present) must be applied manually with docker run volume mounts."
