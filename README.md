# CloudSprite plugin

Public plugin for [CloudSprite](https://cloudsprite.io). One repo, one plugin slug (`cloudsprite`), for Claude Code, Grok Build, and [Agent Plugins](https://agent-plugins.org/specification) clients (Cursor, GitHub Copilot, VS Code, Codex, and others).

The plugin talks to **production** CloudSprite over remote MCP. There are no API keys, GitLab tokens, Linear tokens, or other secrets in this repository. OAuth tokens stay in the **client**.

Plugin `name` is `cloudsprite` and is immutable once a marketplace lists it. The GitHub org is `cloudsprite-io` because `cloudsprite` was already taken on GitHub.

## Connect your AI to CloudSprite

Full per-client steps: [Connect your AI to CloudSprite](https://docs.cloudsprite.io/platform/connect-your-ai/).

There is no API key in this repo and none in chat. Sign in with the same CloudSprite account you use in the browser.

| What | Value |
|-|-|
| MCP URL | `https://api.cloudsprite.io/mcp` |
| Transport | Streamable HTTP |
| OAuth discovery | `https://api.cloudsprite.io/.well-known/oauth-authorization-server` |
| Plugin slug | `cloudsprite` (fixed) |

### How do I connect Claude Code to CloudSprite?

```text
/plugin marketplace add cloudsprite-io/cloudsprite-plugin
/plugin install cloudsprite@cloudsprite
```

Enable the `cloudsprite` plugin if it is not already on. On first tool use, complete the browser sign-in.

### How do I connect Cursor, GitHub Copilot, VS Code, or Codex to CloudSprite?

This repo is an [Agent Plugins 1.0](https://agent-plugins.org/specification) package: root `plugin.json`, `mcp.json`, and `skills/`.

1. Clone this repository (or add `cloudsprite-io/cloudsprite-plugin` as the plugin source if your client accepts a git URL).
2. Load it as an Agent Plugin. In Cursor, a local checkout under `~/.cursor/plugins/local/cloudsprite` is enough.
3. Enable the plugin and complete OAuth when the client prompts.

If the client cannot load Agent Plugins, add a remote MCP server instead (same URL and OAuth as [any MCP client](#how-do-i-connect-any-mcp-client-to-cloudsprite)).

### How do I connect Grok to CloudSprite?

```text
grok plugin marketplace add cloudsprite-io/cloudsprite-plugin
grok plugin install cloudsprite --trust
```

Official listing on xAI’s marketplace is separate and not required for this install. Maintainer catalog notes: [DIRECTORY.md](DIRECTORY.md).

### How do I connect any MCP client to CloudSprite?

| Setting | Value |
|-|-|
| Server URL | `https://api.cloudsprite.io/mcp` |
| Transport | Streamable HTTP |
| OAuth discovery | `https://api.cloudsprite.io/.well-known/oauth-authorization-server` |

The client must discover authorization, token, and JWKS URLs from that metadata. Do not hard-code those hosts, and do not put a client secret or API key in the config.

```json
{
  "mcpServers": {
    "cloudsprite": {
      "type": "streamable-http",
      "url": "https://api.cloudsprite.io/mcp"
    }
  }
}
```

Some clients use `"type": "http"` or a bare `"url"` field for the same remote server.

### How do I connect ChatGPT to CloudSprite?

ChatGPT connectors are **coming soon**. Do not add CloudSprite as a ChatGPT custom connector yet — that OAuth redirect is not registered. Use Claude Code, Cursor, Copilot, Codex, Grok, or a generic MCP client today.

## What it does

After you sign in and set scope, the model can:

- Read org / team / project context (`whoami` / `get_scope`, `list_orgs`, `list_teams`, `list_projects`, `set_scope`)
- Search datasets, traces (summaries only), notebooks, and scripts
- Search CloudSprite product docs and the SDK catalog (`search_knowledge`, `search_sdk`)
- File a bug or feature request (`/feedback` → MCP `submit_feedback`)

This release is **read-only** plus feedback. It does not mutate datasets, tags, notebooks, or scripts.

## MCP URL

Production (the only URL customers use):

```text
https://api.cloudsprite.io/mcp
```

Transport: MCP Streamable HTTP. No `Authorization` header is stored in the plugin. The client discovers OAuth from the MCP origin and holds the tokens. There is no environment picker in the plugin UI.

A 401 from `/mcp` before OAuth is live is expected. The plugin should fail with a clear auth error, not hang.

Claude Code honors `CLOUDSPRITE_MCP_URL` if the client process has it set (`${CLOUDSPRITE_MCP_URL:-https://api.cloudsprite.io/mcp}` in `.mcp.json`). The GUI app reads `~/.claude/settings.json` `"env"`, not your shell profile. Portable `mcp.json` is a literal production URL (no interpolation). Do not commit a `.env` here.

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

Installing the plugin also clones this GitHub repository (`https://github.com/cloudsprite-io/cloudsprite-plugin`). Tagged releases are `vMAJOR.MINOR.PATCH` matching `plugin.json` `version`.

The plugin does **not** call GitLab, Linear, HubSpot, or any issue tracker. Feedback is filed by the CloudSprite API after `submit_feedback`.

If `CLOUDSPRITE_MCP_URL` is set, discovery and token endpoints follow that host instead of `api.cloudsprite.io`.

## Support

- Product: [https://cloudsprite.io](https://cloudsprite.io)
- Docs: [https://docs.cloudsprite.io](https://docs.cloudsprite.io)
- Email: [support@cloudsprite.io](mailto:support@cloudsprite.io)
- Privacy: [privacy@cloudsprite.io](mailto:privacy@cloudsprite.io)

## Releases

Git tags are `v` + the `version` in `plugin.json` (currently `0.1.3`). Maintainers publish with `scripts/publish.sh` after `scripts/audit.sh` passes. Republishing the same tag is a no-op if `HEAD` still matches; a different tree at the same version fails.

## License

[MIT](LICENSE). Copyright © 2026 Brushfield Ventures LLC d/b/a CloudSprite.

Product use of CloudSprite remains under the [CloudSprite Terms of Service](https://cloudsprite.io/terms) and [Privacy Policy](https://cloudsprite.io/privacy).
