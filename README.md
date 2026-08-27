# CloudSprite plugin

Public plugin for [CloudSprite](https://cloudsprite.io). One repo, one plugin slug (`cloudsprite`), for Claude Code, Grok Build, and [Agent Plugins](https://agent-plugins.org/specification) clients (Cursor, GitHub Copilot, VS Code, Codex, and others).

The plugin talks to **production** CloudSprite over remote MCP. There are no API keys, GitLab tokens, Linear tokens, or other secrets in this repository. OAuth tokens stay in the **client**.

Plugin `name` is `cloudsprite` and is immutable once a marketplace lists it. The GitHub org is `cloudsprite-io` because `cloudsprite` was already taken on GitHub.

## Install

### Claude Code

```text
/plugin marketplace add cloudsprite-io/cloudsprite-plugin
/plugin install cloudsprite@cloudsprite
```

On first MCP use the client should start an OAuth 2.1 (PKCE) sign-in against CloudSprite.

### Grok Build

This repo carries a Grok catalog (`.grok-plugin/`) so the same tree can be SHA-pinned later. Official listing on `xai-org/plugin-marketplace` is **not** part of this bootstrap.

### Agent Plugins clients

Point the client at this repository (or a local checkout). Root `plugin.json` + `mcp.json` are the portable Agent Plugins 1.0 payload. Skills live under `skills/`.

## What it does

After you sign in and set scope, the model can:

- Read org / team / project context (`whoami` / `get_scope`, `list_orgs`, `list_teams`, `list_projects`, `set_scope`)
- Search datasets, traces (summaries only), notebooks, and scripts
- Search CloudSprite product docs and the SDK catalog (`search_knowledge`, `search_sdk`)
- File a bug or feature request (`/feedback` → MCP `submit_feedback`)

This release is **read-only** plus feedback. It does not mutate datasets, tags, notebooks, or scripts.

## MCP URL

Customers: do nothing. Production is the default:

```text
https://api.cloudsprite.io/mcp
```

Transport: MCP Streamable HTTP. No `Authorization` header is stored in the plugin. The client discovers OAuth from the MCP origin and holds the tokens. There is no environment switcher in the customer UI.

### Staff override (Claude Code)

Claude Code can retarget MCP without a second plugin:

1. **Plugin config** — `/plugin` → CloudSprite → **MCP URL** (saved in user settings `pluginConfigs`, not this repo).
2. **Environment** — `CLOUDSPRITE_MCP_URL` in the process environment, or in `~/.claude/settings.json` under `"env"`. If set, this wins over the plugin config value.

Examples: `https://dev-api.cloudsprite.io/mcp` (hosted-dev) or `http://localhost:8000/mcp` (local). OAuth metadata is read from **that** host (`/.well-known/oauth-authorization-server`).

The GUI Claude app does **not** load your shell profile (`~/.zshrc`). Prefer `~/.claude/settings.json` `"env"` over exporting the variable only in zsh.

Do not put this URL in a goshen `.env` file. Customers never load that file, and this public plugin must not ship one.

### Grok / Agent Plugins

The portable `mcp.json` is a **literal** production URL. Those hosts do not interpolate `${}` in MCP URLs; an unexpanded string would be fetched as-is. Override the MCP URL in the **client** if you need hosted-dev or local.

A 401 from `/mcp` before OAuth is live is expected. The plugin should fail with a clear auth error, not hang.

## Skills

| Skill | Slash | Purpose |
|-|-|
| `feedback` | `/feedback` | Confirm text, then call MCP `submit_feedback` |
| `platform-howtos` | `/platform-howtos` | Sign-in, scope, and how to use CloudSprite from the assistant |
| `datasets` | `/datasets` | Find datasets, parameters, tags, and notebooks (read) |
| `mixed-mode-analysis` | `/mixed-mode-analysis` | Differential / common-mode S-parameters from 2-port pairs |
| `waveform-correlation` | `/waveform-correlation` | Pairwise Pearson QC across repeated traces |

## Network endpoints

The plugin package does not open sockets itself. **Clients** that load it will contact:

| URL | Why |
|-|-|
| `https://api.cloudsprite.io/mcp` | MCP Streamable HTTP (tools) |
| `https://api.cloudsprite.io/.well-known/oauth-authorization-server` | OAuth 2.1 authorization-server metadata |
| `https://api.cloudsprite.io/.well-known/oauth-protected-resource` | OAuth protected-resource metadata (if advertised) |
| Authorization, token, revocation, and JWKS URLs from that metadata | Cognito Hosted UI PKCE. Hosts are **not** hardcoded here; they come from discovery. |

Installing the plugin also clones this GitHub repository (`https://github.com/cloudsprite-io/cloudsprite-plugin`).

The plugin does **not** call GitLab, Linear, HubSpot, or any issue tracker. Feedback is filed by the CloudSprite API after `submit_feedback`.

If Claude Code is pointed at another origin (plugin **MCP URL** or `CLOUDSPRITE_MCP_URL`), replace `api.cloudsprite.io` in the table with that host. Discovery and token endpoints follow it. `http://localhost:8000` is valid for local staff use.

## License

[MIT](LICENSE). Copyright © 2026 Brushfield Ventures LLC d/b/a CloudSprite.

Product use of CloudSprite remains under the [CloudSprite Terms of Service](https://cloudsprite.io/terms) and [Privacy Policy](https://cloudsprite.io/privacy).
