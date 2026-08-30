# Official MCP Registry (do not publish until the promote gate is green)

Packet: [server.json](server.json)

- Name: `io.github.cloudsprite-io/cloudsprite` (GitHub-org namespace; `mcp-publisher login github` as a `cloudsprite-io` org member)
- Remote: Streamable HTTP `https://api.cloudsprite.io/mcp`
- Version: `0.1.3` (bump with `plugin.json` on the next tagged plugin release)

Remote-only entries do **not** need an npm package. Do not add `headers` for an API key — clients must use OAuth discovery.

Optional later: DNS namespace `io.cloudsprite/mcp` after proving `cloudsprite.io` (TXT `_mcp-server-name.cloudsprite.io` or whatever `mcp-publisher login dns` prints). GitHub namespace is enough for the first publish.

## Commands (copy-paste when the gate is green)

```text
brew install mcp-publisher   # or the release tarball from modelcontextprotocol/registry

cd listings
mcp-publisher validate server.json
# If validate wants cwd server.json:
cp server.json /tmp/cloudsprite-server.json && cd /tmp
mcp-publisher login github
mcp-publisher validate
mcp-publisher publish
```

Confirm:

```text
curl "https://registry.modelcontextprotocol.io/v0.1/servers?search=io.github.cloudsprite-io/cloudsprite"
```

PulseMCP ingests this registry; prefer this publish over the paused PulseMCP form.
