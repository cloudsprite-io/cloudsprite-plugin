# Listing packets

Prepared for api#303 / api#322. Prod MCP OAuth is live (2026-08-31).
Official registry **published** 2026-08-31: `io.github.cloudsprite-io/cloudsprite`
0.1.3 (`description` ≤100 chars). Grok marketplace PR:
https://github.com/xai-org/plugin-marketplace/pull/453

`https://api.cloudsprite.io/.well-known/oauth-authorization-server` returns 200
JSON and `/mcp` returns 401 until the client finishes PKCE. Claude directory
forms still need the demo org, icon, and screenshots before submit.

Self-serve GitHub install can stay:

```text
/plugin marketplace add cloudsprite-io/cloudsprite-plugin
```

Plugin slug `cloudsprite` is **immutable** once a directory lists it.

| Packet | File | Submit where |
|-|-|-|
| Official MCP registry | [server.json](server.json) | **Published** 2026-08-31 — `mcp-publisher publish` |
| PulseMCP | [pulsemcp.md](pulsemcp.md) | Official registry first; PulseMCP form is paused and ingests the registry |
| mcp.so | [mcp-so.md](mcp-so.md) | https://mcp.so/submit |
| Claude directory | [../DIRECTORY.md](../DIRECTORY.md) | Claude.ai + Console forms |
| Grok marketplace | [grok-marketplace-entry.json](grok-marketplace-entry.json) | [PR #453](https://github.com/xai-org/plugin-marketplace/pull/453) open |

After this branch merges to `main`, re-pin the Grok `source.sha` to
`git rev-parse origin/main` (40 hex chars). The JSON in this folder is pinned
to the `main` tip at packet authoring time.

No secrets belong in this tree. IndexNow / DNS verification tokens live in
Cloudflare / Google / Bing, not here.
