# Grok marketplace PR

Fork https://github.com/xai-org/plugin-marketplace, branch from `main`, add
**one** remote entry (do not vendor files under `external_plugins/`).

Prod MCP OAuth is live (2026-08-31): discovery at
`https://api.cloudsprite.io/.well-known/oauth-authorization-server` returns 200.
Grok CLI `mcp doctor` reaches the server and fails at `AuthorizationRequired`
until the user authenticates in the TUI (`/mcps` then `i`). Tokens land in
`~/.grok/mcp_credentials.json`.

## Pin

`source.sha` must be the full 40-char commit of `cloudsprite-io/cloudsprite-plugin`
`main`. Update [grok-marketplace-entry.json](grok-marketplace-entry.json) after
the payload commit lands:

```text
git ls-remote https://github.com/cloudsprite-io/cloudsprite-plugin.git refs/heads/main
```

Paste the object from [grok-marketplace-entry.json](grok-marketplace-entry.json)
into `.grok-plugin/marketplace.json` (or the catalog path that repo uses on
`main` at submit time). Then:

```text
python3 scripts/generate-plugin-index.py
python3 scripts/validate-catalog.py
python3 scripts/generate-plugin-index.py --check
```

PR title: `Add CloudSprite plugin (remote SHA pin)`

Do not use a personal-account `source.url`. Do not pin `main` or tag `v0.1.4`
as the SHA — pin the commit.

Grok token storage: CLI `mcp doctor` returns `AuthorizationRequired` until the
user signs in via TUI `/mcps` then `i`. Tokens are written to
`~/.grok/mcp_credentials.json`.
