# mcp.so submission

Form: https://mcp.so/submit

Do **not** submit until the prod promote gate is green. Do **not** pay the $39
“publish immediately” upsell unless a human explicitly wants featured placement.

## Form answers

| Field | Value |
|-|-|
| Repository URL | https://github.com/cloudsprite-io/cloudsprite-plugin |
| Name | CloudSprite |
| Short description | Talk to CloudSprite as the signed-in user: search datasets and docs, set org/team/project scope, and file product feedback. |
| Homepage | https://cloudsprite.io |
| Documentation | https://docs.cloudsprite.io/platform/connect-your-ai/ |
| License | MIT |
| Transport | Streamable HTTP |
| MCP URL | `https://api.cloudsprite.io/mcp` |
| Auth | OAuth 2.1 + PKCE (no API key in the repo) |

Config snippet to paste if the form asks:

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

If the form only wants a GitHub URL, that is enough — they scrape the README.
