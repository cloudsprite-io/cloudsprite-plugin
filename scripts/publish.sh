#!/usr/bin/env bash
# Tag and optionally push a public CloudSprite plugin release from this tree.
#
# Authoring tree is this repo (customer skills, not sprite-plugin internals).
# Internal plugin/skills/{datasets,mixed-mode-analysis,waveform-correlation}
# are staff/write copies and must never be rsync'd here.
#
# Usage:
#   scripts/publish.sh --check
#   scripts/publish.sh --release
#   scripts/publish.sh --release --push
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

CHECK=0
RELEASE=0
PUSH=0
for arg in "$@"; do
  case "$arg" in
    --check) CHECK=1 ;;
    --release) RELEASE=1 ;;
    --push) PUSH=1 ;;
    -h|--help)
      sed -n '2,16p' "$0"
      exit 0
      ;;
    *)
      echo "unknown arg: $arg" >&2
      exit 2
      ;;
  esac
done
if [[ "$CHECK" -eq 0 && "$RELEASE" -eq 0 ]]; then
  echo "usage: scripts/publish.sh --check | --release [--push]" >&2
  exit 2
fi

"$ROOT/scripts/audit.sh"

VERSION="$(python3 -c 'import json; print(json.load(open("plugin.json"))["version"])')"
TAG="v$VERSION"
REMOTE="${REMOTE:-origin}"
BRANCH="$(git rev-parse --abbrev-ref HEAD)"

if [[ "$BRANCH" != "main" ]]; then
  echo "publish: refuse to tag from branch '$BRANCH' (must be main)" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "publish: working tree not clean" >&2
  git status --porcelain >&2
  exit 1
fi

HEAD="$(git rev-parse HEAD)"
HEAD_SHORT="$(git rev-parse --short HEAD)"

print_grok_entry() {
  python3 - "$1" <<'PY'
import json, sys
sha = sys.argv[1]
entry = {
    "name": "cloudsprite",
    "description": "Talk to CloudSprite as the signed-in user: search datasets and docs, set org/team/project scope, and file product feedback.",
    "source": {
        "source": "url",
        "url": "https://github.com/cloudsprite-io/cloudsprite-plugin.git",
        "sha": sha,
    },
    "homepage": "https://github.com/cloudsprite-io/cloudsprite-plugin",
    "keywords": ["cloudsprite", "cloudsprite mcp", "s-parameters", "mixed-mode"],
    "domains": ["cloudsprite.io", "api.cloudsprite.io", "docs.cloudsprite.io"],
}
print(json.dumps(entry, indent=2))
PY
}

if git rev-parse "$TAG" >/dev/null 2>&1; then
  EXISTING="$(git rev-parse "$TAG^{commit}")"
  if [[ "$EXISTING" != "$HEAD" ]]; then
    echo "publish: tag $TAG already exists at $EXISTING but HEAD is $HEAD" >&2
    echo "publish: bump plugin.json version (and the other manifests) to republish" >&2
    exit 1
  fi
  echo "publish: tag $TAG already points at HEAD ($HEAD)"
else
  if [[ "$CHECK" -eq 1 ]]; then
    echo "publish: would create annotated tag $TAG at $HEAD"
  else
    git tag -a "$TAG" -m "CloudSprite plugin $TAG"
    echo "publish: created $TAG at $HEAD"
  fi
fi

echo "publish: grok SHA-pin entry (do not open the xAI PR until prod /mcp quotas are live):"
print_grok_entry "$HEAD"

if [[ "$CHECK" -eq 1 ]]; then
  echo "publish: check OK (no push)"
  exit 0
fi

if [[ "$PUSH" -eq 1 ]]; then
  git push "$REMOTE" HEAD
  git push "$REMOTE" "$TAG"
  if command -v gh >/dev/null 2>&1; then
    if gh release view "$TAG" --repo cloudsprite-io/cloudsprite-plugin >/dev/null 2>&1; then
      echo "publish: GitHub release $TAG already exists"
    else
      gh release create "$TAG" \
        --repo cloudsprite-io/cloudsprite-plugin \
        --title "$TAG" \
        --notes "$(cat <<EOF
Public CloudSprite plugin $TAG.

- Slug: \`cloudsprite\` (immutable once a marketplace lists it)
- MCP: \`https://api.cloudsprite.io/mcp\`
- Skills: datasets, mixed-mode-analysis, waveform-correlation, platform-howtos, sync-context, feedback
- License: MIT

Install: \`/plugin marketplace add cloudsprite-io/cloudsprite-plugin\` then \`/plugin install cloudsprite@cloudsprite\`

Commit: \`$HEAD\`
EOF
)"
      echo "publish: GitHub release $TAG created"
    fi
  else
    echo "publish: gh not on PATH; tag pushed, create the GitHub release by hand" >&2
  fi
else
  echo "publish: tag local only. Re-run with --push to push $TAG and create the GitHub release."
fi

echo "publish: SHA $HEAD ($HEAD_SHORT) tag $TAG"
