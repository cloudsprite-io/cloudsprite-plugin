# Listing packets — do not submit yet

Prepared for api#303 / api#322. Prod MCP OAuth is live (2026-08-31):
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
| Official MCP registry | [server.json](server.json) | `mcp-publisher publish` (see below) |
| PulseMCP | [pulsemcp.md](pulsemcp.md) | Official registry first; PulseMCP form is paused and ingests the registry |
| mcp.so | [mcp-so.md](mcp-so.md) | https://mcp.so/submit |
| Claude directory | [../DIRECTORY.md](../DIRECTORY.md) | Claude.ai + Console forms |
| Grok marketplace | [grok-marketplace-entry.json](grok-marketplace-entry.json) | PR to `xai-org/plugin-marketplace` — **do not open until gate is green** |

After this branch merges to `main`, re-pin the Grok `source.sha` to
`git rev-parse origin/main` (40 hex chars). The JSON in this folder is pinned
to the `main` tip at packet authoring time.

No secrets belong in this tree. IndexNow / DNS verification tokens live in
Cloudflare / Google / Bing, not here.
