# Directory listing packet

Fill-in answers for the Claude plugin directory form and the Grok SHA-pin PR. **Do not submit either listing until production `https://api.cloudsprite.io/mcp` serves MCP (OAuth + rate limits).** Self-serve GitHub install (`/plugin marketplace add cloudsprite-io/cloudsprite-plugin`) can stay.

Registry / PulseMCP / mcp.so / Grok JSON packets: [listings/](listings/). Grok pin in this file is the tagged `v0.1.4` SHA; the listings packet tracks current `main` and must be re-pinned after that branch merges.

Submitter: a CloudSprite org owner. Forms:

- Claude.ai: https://claude.ai/admin-settings/directory/submissions/plugins/new
- Console: https://platform.claude.com/plugins/submit
- Status: https://claude.ai/admin-settings/directory/submissions
- Grok: PR to https://github.com/xai-org/plugin-marketplace (fork, one catalog entry)

Run `claude plugin validate --strict .` and `scripts/audit.sh` before submitting. Plugin slug `cloudsprite` is **immutable** once listed.

## Claude form

| Field | Answer |
|-|-|
| Plugin name / slug | `cloudsprite` |
| Display name | CloudSprite |
| GitHub repository | https://github.com/cloudsprite-io/cloudsprite-plugin |
| Version | `0.1.4` (tag `v0.1.4`) |
| License | MIT |
| Homepage | https://cloudsprite.io |
| Documentation | https://docs.cloudsprite.io |
| Privacy policy | https://cloudsprite.io/privacy |
| Terms | https://cloudsprite.io/terms |
| Support | support@cloudsprite.io |
| Privacy contact | privacy@cloudsprite.io |
| Author | CloudSprite (Brushfield Ventures LLC d/b/a CloudSprite) |
| Short description | Talk to CloudSprite as the signed-in user: search datasets and docs, set org/team/project scope, and file product feedback. |
| Category | Test and measurement / RF / signal integrity |

### Long description (paste)

CloudSprite is a measurement-data platform for RF and signal-integrity work. This plugin connects Claude to the customer's CloudSprite account over remote MCP (Streamable HTTP). After OAuth, the model can search datasets, traces (summaries only), notebooks, and scripts in the bound org/team/project; search product docs and the Python SDK catalog; run mixed-mode and waveform-QC skills; sync the team's instruction files into local rules files; and file confidential product feedback.

The plugin is **read-only** plus `submit_feedback`. It does not mutate datasets, tags, notebooks, or scripts. There are no API keys or tracker tokens in the repository. OAuth tokens stay in the client.

Install from GitHub (works before directory listing):

```text
/plugin marketplace add cloudsprite-io/cloudsprite-plugin
/plugin install cloudsprite@cloudsprite
```

### Network endpoints (disclose all)

The plugin package does not open sockets. Clients that load it contact:

| URL | Why |
|-|-|
| `https://api.cloudsprite.io/mcp` | MCP Streamable HTTP |
| `https://api.cloudsprite.io/.well-known/oauth-authorization-server` | OAuth 2.1 authorization-server metadata |
| `https://api.cloudsprite.io/.well-known/oauth-protected-resource` | OAuth protected-resource metadata |
| `https://api.cloudsprite.io/oauth/authorize` | PKCE authorize (from metadata) |
| `https://api.cloudsprite.io/oauth/token` | Token (from metadata) |
| `https://api.cloudsprite.io/oauth/register` | Dynamic client registration (from metadata, if advertised) |
| Cognito Hosted UI, JWKS, revocation | From discovery. Not hardcoded. Hosted-dev (not customer) currently uses `cognito-idp.us-east-2.amazonaws.com` and `*.auth.us-east-2.amazoncognito.com`. |
| `https://github.com/cloudsprite-io/cloudsprite-plugin` | Plugin install clone |
| `https://docs.cloudsprite.io` | Linked from OAuth `service_documentation` |

No GitLab, Linear, HubSpot, or other tracker is called from the plugin. Feedback is filed by the CloudSprite API after `submit_feedback`.

Staff-only: `CLOUDSPRITE_MCP_URL` retargets Claude Code at another origin (for example `https://dev-api.cloudsprite.io/mcp`). Customers never set this.

### Auth

OAuth 2.1 with PKCE. `token_endpoint_auth_methods_supported: none` (public client). Scopes: `openid email profile`. No client secret in the plugin.

### Example prompts (need ≥ 3)

1. "Which datasets in this project have lot=15?"
2. "Set my CloudSprite scope to the team and project I pick, then show me what I can see."
3. "Walk me through mixed-mode SDD21 from these four port-pair S2P files. Confirm the port mapping first."
4. "Find outlier S21 traces in this batch using pairwise Pearson correlation."
5. "/sync-context — pull my team's CloudSprite instruction files into this repo"
6. "/feedback the S2P export drops comments"

### Screenshots to capture (attach in the form)

1. `/plugin marketplace add cloudsprite-io/cloudsprite-plugin` then `/plugin install cloudsprite@cloudsprite` succeeding.
2. Client OAuth / CloudSprite sign-in in the browser.
3. A read query (`search_datasets` or `get_scope`) returning the signed-in team's data.
4. Optional: `/feedback` confirmation, then a filed-id result.

Do **not** screenshot customer data from a paying tenant. Use the Anthropic test account (below).

### Test account (Anthropic reviewers)

Create a dedicated CloudSprite user in a **demo** org/team/project with a handful of non-customer S2P files (mixed-mode port-pair set + a small S21 batch). Read-only is enough. Put credentials only in the form, never in this repo.

### Icon

512×512 PNG of the CloudSprite mark (transparent or light background). Not in this repo — attach in the form.

## Grok SHA-pin (same repo, do not open until prod MCP is live)

Fork https://github.com/xai-org/plugin-marketplace, branch from `main`, add **one** remote entry to `.grok-plugin/marketplace.json`, regenerate `.grok-plugin/plugin-index.json`, run:

```text
python3 scripts/generate-plugin-index.py
python3 scripts/validate-catalog.py
python3 scripts/generate-plugin-index.py --check
```

`scripts/publish.sh` prints the JSON with the real 40-char SHA after a tag. Template:

```json
{
  "name": "cloudsprite",
  "description": "Talk to CloudSprite as the signed-in user: search datasets and docs, set org/team/project scope, and file product feedback.",
  "source": {
    "source": "url",
    "url": "https://github.com/cloudsprite-io/cloudsprite-plugin.git",
    "sha": "PIN_SHA_40_LOWERCASE"
  },
  "homepage": "https://github.com/cloudsprite-io/cloudsprite-plugin",
  "keywords": ["cloudsprite", "cloudsprite mcp", "s-parameters", "mixed-mode"],
  "domains": ["cloudsprite.io", "api.cloudsprite.io", "docs.cloudsprite.io"]
}
```

PR title: `Add CloudSprite plugin (remote SHA pin)`.

Do not vendor files under `external_plugins/`. Do not use a personal-account source. Pin a commit, not `main` or `v0.1.4`.

## What this plugin is not

- Not a second Grok repo
- Not sprite-plugin (no review agents, runbooks, finance, Linear, or internal standards)
- Not the `.com` TLD (we do not own it; production MCP is `api.cloudsprite.io`)
