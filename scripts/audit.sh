#!/usr/bin/env bash
# Audit the public CloudSprite plugin payload.
# Fail if extra files, secrets, internals, or a wrong MCP URL are in git.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "audit: not a git repo: $ROOT" >&2
  exit 1
fi

PROD_MCP='https://api.cloudsprite.io/mcp'
fail=0
note() { printf '%s\n' "$*"; }
err()  { printf 'FAIL: %s\n' "$*" >&2; fail=1; }

# Allowlist, slug, MCP URL, versions — one Python pass.
python3 - "$PROD_MCP" <<'PY' || fail=1
import json, os, sys
from pathlib import Path

prod = sys.argv[1]
fail = 0

ALLOWLIST = {
    ".claude-plugin/marketplace.json",
    ".claude-plugin/plugin.json",
    ".gitignore",
    ".grok-plugin/marketplace.json",
    ".grok-plugin/plugin.json",
    ".mcp.json",
    "DIRECTORY.md",
    "LICENSE",
    "README.md",
    "listings/README.md",
    "listings/grok-marketplace-entry.json",
    "listings/grok-pr.md",
    "listings/mcp-so.md",
    "listings/official-registry.md",
    "listings/pulsemcp.md",
    "listings/server.json",
    "mcp.json",
    "plugin.json",
    "scripts/audit.sh",
    "scripts/publish.sh",
    "skills/datasets/SKILL.md",
    "skills/feedback/SKILL.md",
    "skills/mixed-mode-analysis/SKILL.md",
    "skills/platform-howtos/SKILL.md",
    "skills/sync-context/SKILL.md",
    "skills/waveform-correlation/SKILL.md",
}
CUSTOMER_SKILLS = [
    "datasets",
    "feedback",
    "mixed-mode-analysis",
    "platform-howtos",
    "sync-context",
    "waveform-correlation",
]

def err(msg):
    global fail
    print(f"FAIL: {msg}", file=sys.stderr)
    fail = 1

def load(p):
    return json.loads(Path(p).read_text())

tracked = set(os.popen("git ls-files").read().splitlines())
untracked = set(
    os.popen("git ls-files --others --exclude-standard").read().splitlines()
)
on_disk = {p for p in ALLOWLIST if Path(p).is_file()}
for f in sorted(tracked - ALLOWLIST):
    err(f"tracked file not on allowlist: {f}")
for f in sorted(untracked - ALLOWLIST):
    err(f"untracked file not on allowlist: {f}")
for f in sorted(ALLOWLIST - on_disk):
    err(f"required file missing: {f}")

skill_root = Path("skills")
if skill_root.is_dir():
    found = sorted(p.name for p in skill_root.iterdir() if p.is_dir())
    if found != CUSTOMER_SKILLS:
        err(f"skills/ must be exactly {CUSTOMER_SKILLS} (found: {found})")
    for s in CUSTOMER_SKILLS:
        if not (skill_root / s / "SKILL.md").is_file():
            err(f"missing skills/{s}/SKILL.md")

versions = {}
for p in [
    "plugin.json",
    ".claude-plugin/plugin.json",
    ".claude-plugin/marketplace.json",
    ".grok-plugin/plugin.json",
    ".grok-plugin/marketplace.json",
]:
    data = load(p)
    if p.endswith("marketplace.json"):
        plugs = data.get("plugins") or []
        if len(plugs) != 1:
            err(f"{p}: expected exactly one plugin entry")
            continue
        name = plugs[0].get("name")
        ver = plugs[0].get("version")
        src = plugs[0].get("source")
        if name != "cloudsprite":
            err(f"{p}: plugin name must be 'cloudsprite' (got {name!r})")
        if src not in ("./",):
            err(f"{p}: source must be './' (got {src!r})")
        versions[p] = ver
        if data.get("name") != "cloudsprite":
            err(f"{p}: marketplace name must be 'cloudsprite' (got {data.get('name')!r})")
    else:
        if data.get("name") != "cloudsprite":
            err(f"{p}: name must be 'cloudsprite' (got {data.get('name')!r})")
        versions[p] = data.get("version")

vs = {v for v in versions.values() if v}
if len(vs) != 1:
    err(f"version mismatch across manifests: {versions}")

mcp = load("mcp.json")
url = (mcp.get("mcpServers") or {}).get("cloudsprite", {}).get("url")
if url != prod:
    err(f"mcp.json url must be {prod} (got {url!r})")
if "${" in json.dumps(mcp):
    err("mcp.json must be a literal URL (no ${} interpolation)")

dot = load(".mcp.json")
dot_url = (dot.get("mcpServers") or {}).get("cloudsprite", {}).get("url")
expected = "${CLOUDSPRITE_MCP_URL:-" + prod + "}"
if dot_url != expected:
    err(f".mcp.json url must be {expected} (got {dot_url!r})")

import re
SECRET_RE = re.compile(
    r"glpat-|ghp_[A-Za-z0-9]|github_pat_|gho_[A-Za-z0-9]|sk-ant-|"
    r"AKIA[0-9A-Z]{16}|BEGIN (RSA |OPENSSH |EC |PRIVATE)|client_secret"
)
INTERNAL_RE = re.compile(
    r"/sprite:(autodev|dispatch|debrief|start|review|scrum|finance|linear)|"
    r"cloudsprite-knowledge|ready-to-start|api\.cloudsprite\.com"
)
for rel in sorted(ALLOWLIST):
    path = Path(rel)
    if not path.is_file():
        continue
    # This scanner file contains the patterns it looks for.
    if rel == "scripts/audit.sh":
        continue
    text = path.read_text(errors="replace")
    if SECRET_RE.search(text):
        err(f"secret-like pattern in {rel}")
    if INTERNAL_RE.search(text):
        err(f"internal / private material in {rel}")
    if rel.endswith(".json") and "client_secret" in text:
        err(f"secret-like string 'client_secret' in {rel}")

sys.exit(fail)
PY

# History: credential-shaped strings only. Bootstrap once pinned the unowned
# .com host; that is a TLD mistake, later fixed, not a secret.
SECRET_RE='glpat-|ghp_[A-Za-z0-9]|github_pat_|gho_[A-Za-z0-9]|sk-ant-|AKIA[0-9A-Z]{16}|BEGIN (RSA |OPENSSH |EC |PRIVATE)|client_secret'
set +e
git grep -I -n -E "$SECRET_RE" $(git rev-list --all) -- ':!scripts/audit.sh' >/tmp/audit-hist-secrets.txt 2>/dev/null
hist_rc=$?
set -e
if [[ "$hist_rc" -eq 0 && -s /tmp/audit-hist-secrets.txt ]]; then
  err "secret-like pattern in git history:"
  cat /tmp/audit-hist-secrets.txt >&2 || true
fi

if command -v claude >/dev/null 2>&1; then
  set +e
  claude plugin validate --strict "$ROOT" >/tmp/audit-validate.txt 2>&1
  v1=$?
  claude plugin validate --strict "$ROOT/.claude-plugin/plugin.json" >/tmp/audit-validate-plugin.txt 2>&1
  v2=$?
  set -e
  if [[ "$v1" -ne 0 ]]; then
    err "claude plugin validate --strict failed"
    cat /tmp/audit-validate.txt >&2 || true
  fi
  if [[ "$v2" -ne 0 ]]; then
    err "claude plugin validate plugin.json failed"
    cat /tmp/audit-validate-plugin.txt >&2 || true
  fi
else
  note "audit: claude CLI not on PATH; skipped plugin validate"
fi

if [[ "$fail" -ne 0 ]]; then
  echo "audit: FAILED" >&2
  exit 1
fi

echo "audit: OK"
echo "  slug:    cloudsprite"
echo "  mcp:     $PROD_MCP"
echo "  skills:  datasets feedback mixed-mode-analysis platform-howtos sync-context waveform-correlation"
echo "  version: $(python3 -c 'import json; print(json.load(open("plugin.json"))["version"])')"
