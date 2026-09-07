---
name: datasets
description: >
  Query CloudSprite datasets, parameters, tags, and notebook membership
  through MCP. Use when the user asks which datasets match a parameter or
  tag, what is on a dataset, which notebooks contain a trace, or which
  reports cite a dataset. This skill is read-only — do not modify data.
---

# CloudSprite datasets (read)

Find and describe datasets in the signed-in user's current project.
There are no `search_datasets`, `get_dataset`, `list_notebooks`, or
`get_notebook` MCP tools. Discover `Dataset.*` / `Notebook.*` (and list
methods such as `Client.datasets` / `Project.notebooks`) with `search_sdk`
→ `inspect_sdk` → `use_sdk`. Do not generate scripts, do not call the REST
API with a token, and do not modify parameters, tags, or notebooks.

## Setup

1. Confirm MCP is connected. If not, tell the user to finish OAuth.
2. `get_scope` (or `whoami`). If team/project is unset, `list_teams` /
   `list_projects` and `set_scope` with their choice.
3. Then search.

## SDK reads

| Tool | Arguments |
|-|-|
| `search_sdk` | `query` (string, required); `access` (`"read"` or `"write"`, optional); `domain` (string, optional); `limit` (integer, optional) |
| `inspect_sdk` | `method` (string, required) — catalog **qualname** from search |
| `use_sdk` | `method` (string, required); `args` (object, optional) matching inspect; `confirm_name` unused in this read skill |

Execute a catalog row only after inspect: `rest_path` must be the dataset or
notebook resource you intend (for example GET `/api/datasets/` or
`/api/notebooks/...`). A near-miss on another resource is unavailable, not a
substitute. This skill does not write.

Typical queries: `query="list datasets"` or `"Dataset"` with `access="read"`;
then `query="Notebook"` for notebooks. Qualnames that often exist:
`Client.datasets`, `Project.datasets`, `Dataset.traces`, `Dataset.params`,
`Dataset.slug`, `Project.notebooks`, `Notebook.datasets`, `Notebook.traces`.
Always inspect before calling — do not guess.

## Finding datasets

Map natural language to a `search_sdk` query, inspect the list/detail
qualname, then `use_sdk` with inspected args. Parameter values are strings —
`lot=15` means `"15"`, not `15`.

Examples:

| User says | Do |
|-|-|
| "Which datasets in this project have lot=15?" | `search_sdk` → inspect list method → `use_sdk`; match param `lot` = `"15"` |
| "Show datasets tagged needs-review" | Same path; filter by tag |
| "What is on dataset ABC?" | List/search for the id, then inspect a Dataset.* inventory method |
| "What traces does it have?" | Dataset inventory via `use_sdk`, then `get_trace_summary` per trace |
| "Which notebooks include these?" | `search_sdk` for Notebook.* / `Project.notebooks`, inspect, `use_sdk` |

Always name the **project** you searched and how many rows matched. If
the list is long, summarize and offer to narrow.

## One dataset

Inspected Dataset.* reads return parameters, tags, trace inventory, and
provenance (source type, producing run) when those fields exist. Use them
before answering "what's on this file."

For numeric shape (x-range, point count, min/max/mean, resonances) call
`get_trace_summary`. **Do not** fetch or paste raw sample arrays.

## Notebooks (read)

Inspected Notebook.* / project notebook list methods show membership and
graph contents. Do not create notebooks or bulk-add traces in this read
workflow.

## Which reports cite this dataset?

Resolve the dataset in the bound project with the Dataset.* / list path
above and retain its real ID/slug. Use `search_sdk` to find the dataset
report-backlinks read method, then `inspect_sdk` for its exact method name,
arguments, permissions, `rest_path`, and response shape before calling
`use_sdk`. Execute only when inspected `rest_path` is the backlinks resource
for that dataset (not a Reports write, and not another resource). Do not
guess a method name from an API route or search report body text as a
substitute for the reference graph.

Show returned report titles/slugs and publication state when available.
Use returned links or verified named routes only. Follow the inspected
pagination contract and flag truncated/partial results. Any summary count
is not proof that a single page contains every report. Zero visible
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
match first (SDK list preview).

## Reporting

- Cite dataset **name + id**
- Show matching parameters/tags
- Note RBAC denials instead of retrying as someone else
