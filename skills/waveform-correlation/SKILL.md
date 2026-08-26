---
name: waveform-correlation
description: >
  Detect outlier waveforms in a CloudSprite project with pairwise Pearson
  correlation and describe a clean average of the good traces. Use for
  batch QC on S21, amplitude, or any repeated measurement. MCP is read-only.
---

# Waveform correlation (QC)

Pairwise Pearson correlation across traces in a CloudSprite project:
score each trace, flag outliers, describe a clean average of the rest.

MCP in this plugin is **read-only**. You can find traces and reason about
shape from summaries. You cannot publish an average dataset or an outlier
notebook through MCP.

## Pearson r for waveform QC

Pearson r is linear similarity of two y-arrays: −1 (anti-correlated) to
+1 (same shape).

| r | Meaning |
|-|-|
| ≥ 0.99 | Nearly identical |
| 0.95–0.99 | Similar with natural variation |
| 0.90–0.95 | Noticeable differences |
| < 0.90 | Meaningfully different — likely an outlier |

**Pairwise:** every trace vs every other. A trace's score = mean of its
row in the n×n r matrix, **excluding the diagonal**. Outliers are more
than σ standard deviations **below** the group mean (default σ = 2).

Do **not** average first and then compare to the average — outliers
pollute the reference. Score pairwise, then average only the good traces.

## Ask (or derive) before running

### 1. Project and trace type

`search_datasets` / `get_dataset` in the bound project. List trace names
actually present, then ask which to correlate. If only one type exists
across the set, use it.

### 2. Which datasets

A parameter (batch id), the whole project, or a name pattern. Confirm
the filter and the count.

### 3. X-axis alignment

If summaries show different x-ranges or point counts, ask:

- **Interpolate** to a common grid (full span) — default
- **Trim** to overlap only

### 4. σ

Default **2**. Only ask if they want tighter or looser detection.

Need ≥ 3 traces. Pairwise stats degenerate below that.

## Algorithm (local)

Work on **dB** for S-parameters (`20*log10(|S|)`), not linear magnitude.

```text
1. Align x (interpolate or trim)
2. y_matrix shape (n_traces, n_points)
3. r[i,j] = pearson(y_i, y_j); r[i,i] = 1
4. score_i = mean(r[i, j] for j != i)
5. threshold = mean(scores) − σ * std(scores)
6. outlier if score < threshold
7. clean average = mean of non-outlier rows
```

Always print each trace's score so the user sees the distribution.

If **every** trace flags as an outlier, σ is too tight — say so.

## CloudSprite (this plugin)

1. `set_scope` to the team/project.
2. `search_datasets` with the batch/parameter/name filter.
3. `get_dataset` for ids, names, parameters, trace inventory.
4. `get_trace_summary` for x-range, point count, min/max/mean — enough
   to spot a wildly different file, **not** enough to compute Pearson r
   (that needs the samples).
5. For the actual r matrix the user runs local code (NumPy/SciPy) on
   files they already have, or the Python SDK with **their** credentials.
   This plugin has no token and does not return raw arrays.
6. Do not publish the average or an outlier notebook via MCP. Point them
   at the CloudSprite app to upload results in this release.

## Minimum checks

- ≥ 3 traces
- Do not mix dB and linear y-units
- Exclude the diagonal from the mean score
- If alignment was skipped, say the r values are not meaningful

## Common mistakes

| Mistake | Fix |
|-|-|
| Correlating linear S21 | Convert to dB first |
| Skipping x alignment | Interpolate or trim before `pearsonr` |
| Including the diagonal in the score | Exclude `j == i` |
| Declaring outliers from summaries only | Summaries can hint; r needs samples |
