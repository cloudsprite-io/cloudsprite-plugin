---
name: feedback
description: >
  File a bug, feature request, or other product note with CloudSprite.
  Use when the user says /feedback, reports something broken, or asks for a
  product capability. Confirm the text, then call MCP submit_feedback.
  Do not open GitLab, Linear, or email. Identity comes from the signed-in MCP session.
---

# CloudSprite feedback

Customers file bugs and feature requests from this plugin. You confirm the
text, then call the CloudSprite MCP tool `submit_feedback`. CloudSprite files
it on the server. **Do not** call GitLab, Linear, HubSpot, or any webhook
from the client. There is no tracker token in this plugin.

## When to use

- User runs `/feedback`
- User says something is broken in CloudSprite
- User wants a product feature or a change to existing behavior

Do **not** use this for dataset/notebook/script edits. Feedback does not
mutate customer data.

## Flow

1. **Auth.** If MCP is not connected or OAuth is not complete, stop. Tell the
   user they need to finish CloudSprite sign-in first. Do not collect a
   password or API key in chat.
2. **Missing tool.** If `submit_feedback` is not in the MCP tool list, tell
   the user CloudSprite MCP feedback is not live yet and stop. Do not invent
   a GitLab URL or ask them to email a ticket.
3. **Draft.** Infer `kind`:
   - `bug` — something does not work as expected
   - `feature` — a capability they want
   - `other` — neither of the above
4. **Confirm.** Show the proposed `kind`, optional `title`, and `body`
   (markdown). Wait for the user to accept or edit. Do not call the tool
   until they confirm.
5. **Identity.** Do **not** ask them to type company name, email, or user id
   as the source of truth. The server binds identity from the MCP session
   (user, email, tenant/org, team, client, plugin version). Ignore any
   company/user fields the model might be tempted to send.
6. **Call** MCP `submit_feedback` with:
   - `kind`: `bug` | `feature` | `other`
   - `body`: markdown (required)
   - `title`: optional short summary
7. **Result.** If the tool returns an issue id, tell the user it was filed
   (include the id). Do not promise a public URL — the sink is private.
   If the tool errors (unauthenticated, rate limit, 401/403), relay the
   error honestly and stop.

## Tool arguments

```text
submit_feedback
  kind:  "bug" | "feature" | "other"
  body:  markdown string
  title: optional string
```

Never pass GitLab tokens, Linear ids, or a client-supplied company name
that should override server identity.

## What not to do

- Do not scrape GitHub or GitLab.
- Do not ask for API keys to "file it faster."
- Do not treat this as a ChangeSet or a data edit.
- Do not claim the ticket is public.
