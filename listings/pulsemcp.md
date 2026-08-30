# PulseMCP submission

**Status (2026-08-30): form paused.** https://www.pulsemcp.com/submit says
submissions and listing edits are paused (pipeline overhaul, “until mid-August”
copy still showing). PulseMCP’s own guidance: publish to the **Official MCP
Registry** first; they ingest `registry.modelcontextprotocol.io` and will pick
the server up when the form reopens.

Do **not** email hello@pulsemcp.com until the prod promote gate is green.

## When the form is back (fallback, if registry ingest is slow)

- What: MCP Server
- GitHub repository: https://github.com/cloudsprite-io/cloudsprite-plugin
- Remote URL: `https://api.cloudsprite.io/mcp`
- Transport: Streamable HTTP
- Auth: OAuth 2.1 + PKCE (no API key)
- Display name: CloudSprite
- Short description: Talk to CloudSprite as the signed-in user: search datasets and docs, set org/team/project scope, and file product feedback.
- Docs: https://docs.cloudsprite.io/platform/connect-your-ai/
- Official registry name: `io.github.cloudsprite-io/cloudsprite` ([server.json](server.json))

Optional DNS namespace later: `io.cloudsprite/mcp` (requires proving ownership of `cloudsprite.io`). GitHub-namespace is enough for the first publish.
