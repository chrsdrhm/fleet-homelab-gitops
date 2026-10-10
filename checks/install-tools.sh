#!/usr/bin/env bash
# Installs the pinned actionlint into a folder and, in GitHub Actions, puts it on the
# PATH. A release binary checked against its published SHA-256 checksum. Dependabot
# cannot update it: bump the version and checksum together by hand (the zizmor image
# digest is in run.sh).
# Usage: checks/install-tools.sh [DIR]   (default: $RUNNER_TEMP/bin, else ./.check-tools)
set -euo pipefail

ACTIONLINT_VERSION=1.7.12
case "$(uname -s)-$(uname -m)" in
  Linux-x86_64) os_arch=linux_amd64;  sha=8aca8db96f1b94770f1b0d72b6dddcb1ebb8123cb3712530b08cc387b349a3d8 ;;
  Darwin-arm64) os_arch=darwin_arm64; sha=aba9ced2dee8d27fecca3dc7feb1a7f9a52caefa1eb46f3271ea66b6e0e6953f ;;
  *) echo "No pinned checksum for $(uname -s)-$(uname -m); install actionlint yourself." >&2; exit 1 ;;
esac

dir="${1:-${RUNNER_TEMP:+$RUNNER_TEMP/bin}}"
dir="${dir:-$PWD/.check-tools}"
mkdir -p "$dir"
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT

sha256() { if command -v sha256sum >/dev/null; then sha256sum "$1"; else shasum -a 256 "$1"; fi | cut -d' ' -f1; }
curl -fsSLo "$work/actionlint.tar.gz" "https://github.com/rhysd/actionlint/releases/download/v${ACTIONLINT_VERSION}/actionlint_${ACTIONLINT_VERSION}_${os_arch}.tar.gz"
[ "$(sha256 "$work/actionlint.tar.gz")" = "$sha" ] || { echo "Checksum mismatch for actionlint" >&2; exit 1; }
tar xzf "$work/actionlint.tar.gz" -C "$dir" actionlint

if [ -n "${GITHUB_PATH:-}" ]; then echo "$dir" >> "$GITHUB_PATH"; fi
echo "Installed actionlint ${ACTIONLINT_VERSION} into $dir"
