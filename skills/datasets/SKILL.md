---
name: datasets
description: >
  Query CloudSprite datasets, parameters, tags, and notebook membership
  through MCP read tools. Use when the user asks which datasets match a
  parameter or tag, what is on a dataset, or which notebooks contain a
  trace, or which reports cite a dataset. Read-only — do not modify data.
---

# CloudSprite datasets (read)

Find and describe datasets in the signed-in user's current project.
Execute **MCP read tools** — do not generate scripts, do not call the
REST API with a token, and do not modify parameters, tags, or notebooks.

## Setup

1. Confirm MCP is connected. If not, tell the user to finish OAuth.
2. `get_scope` (or `whoami`). If team/project is unset, `list_teams` /
   `list_projects` and `set_scope` with their choice.
3. Then search.

## Finding datasets

Map natural language to `search_datasets`. Typical filters:

- Name glob or substring
- Parameter predicates (values are strings — `lot=15` means `"15"`, not `15`)
- Tags
- Source / file type when the tool supports it

Examples:

| User says | Do |
|-|-|
| "Which datasets in this project have lot=15?" | `search_datasets` with parameter `lot` = `"15"` |
| "Show datasets tagged needs-review" | `search_datasets` by tag |
| "What is on dataset ABC?" | `search_datasets` to get the id, then `get_dataset` |
| "What traces does it have?" | `get_dataset` (inventory) then `get_trace_summary` per trace |
| "Which notebooks include these?" | `list_notebooks` / `get_notebook` |

Always name the **project** you searched and how many rows matched. If
the list is long, summarize and offer to narrow.

## One dataset

`get_dataset` returns parameters, tags, trace inventory, and provenance
(source type, producing run). Use it before answering "what's on this
file."

For numeric shape (x-range, point count, min/max/mean, resonances) call
`get_trace_summary`. **Do not** fetch or paste raw sample arrays.

## Notebooks (read)

`list_notebooks` / `get_notebook` show membership and graph contents.
Do not create notebooks or bulk-add traces in this read workflow.

## Which reports cite this dataset?

Resolve the dataset in the bound project with `get_dataset` and retain its
real ID/slug. Use `search_sdk` to find the dataset report-backlinks read method,
then `inspect_sdk` for its exact method name, arguments, permissions, and
response shape before calling `use_sdk`. Do not guess a method name from an
API route or search report body text as a substitute for the reference graph.

Show returned report titles/slugs and publication state when available.
Use returned links or verified named routes only. Follow the inspected
pagination contract and flag truncated/partial results. A detail `report_count`
is a summary, not proof that a single page contains every report. Zero visible
results means no reports were returned for this user and scope, not proof of
no citations across all projects or users. Do not enumerate inaccessible reports.

If the catalog lacks the backlinks method, say this connection cannot list
backlinks yet; do not fabricate matches or bypass it with REST. Notebook
backlinks follow the same discovery and visibility rules. To draft a report
from these sources, use the [`reports` skill](../reports/SKILL.md); this read
request alone does not authorize creating a report.

## What you must not do

- Add, update, or delete parameters
- Create or apply tags
- Create notebooks or add/remove traces
- Invent ids
- Query a team/project the user did not bind with `set_scope`

If the user asks to change dataset data, explain that this skill covers reads
and they can edit in the CloudSprite app. Offer to **show** what would
match first (`search_datasets` preview).

## Reporting

- Cite dataset **name + id**
- Show matching parameters/tags
- Note RBAC denials instead of retrying as someone else
