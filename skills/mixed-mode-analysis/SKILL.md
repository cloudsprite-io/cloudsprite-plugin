---
name: mixed-mode-analysis
description: >
  Compute or explain mixed-mode (differential/common-mode) S-parameters from
  single-ended 2-port Touchstone pairs. Use for SDD/SCC/SDC/SCD, CMRR, port
  definitions, or balanced-device questions. Confirm port mapping before
  any math. CloudSprite access is MCP reads only.
---

# Mixed-mode S-parameter analysis

Expert guide for mixed-mode S-parameters from single-ended measurements,
and for reading the source datasets in CloudSprite.

**Reference:** Bert Simonovich, "A Guide for Single-Ended to Mixed-Mode
S-Parameter Conversions," *Signal Integrity Journal*, July 2020.

This plugin's MCP is **read-only**. You may inspect CloudSprite datasets
and explain or compute locally. You may **not** publish new datasets or
notebooks through MCP.

## What mixed-mode is

A VNA measures **single-ended** S-parameters. For a differential device
with 4 ports (2 in, 2 out) that is a 4×4 matrix (16 parameters).

**Mixed-mode** rewrites that matrix into differential and common-mode
behavior:

```text
[ SDD  SDC ]
[ SCD  SCC ]
```

| Quadrant | Stimulus | Response | Meaning |
|-|-|-|-|
| **SDD** | Differential | Differential | Differential gain/loss — primary figure of merit |
| **SCC** | Common | Common | Common-mode transmission |
| **SDC** | Common | Differential | Common → differential conversion |
| **SCD** | Differential | Common | Differential → common conversion |

A well-designed differential path has high SDD21, low SCC21 (rejection),
and near-zero SDC/SCD (balance).

**CMRR (dB):** `|SDD21_dB| − |SCC21_dB|`

A single 2-port measurement cannot separate differential from common
mode. You need all four port-pair interactions.

## Confirm before computing

Wrong port mapping produces numbers that look fine and are physically
wrong. Always verify mapping **before** arithmetic.

### 1. Inspect CloudSprite first

With scope set (`set_scope`):

- `search_datasets` for the four port-pair files (often a shared serial,
  fixture, or `mixed_mode` / `port_pair` / `polarity` parameter)
- `get_dataset` on each for parameters, filenames, and trace inventory

Look for:

1. Port-pair values: `p13`, `p14`, `p23`, `p24`, `PN`, `PP`, `NP`, `NN`
2. Stored filenames (often encode both conventions, e.g. `G6_Probe_p14_PN.s2p`)
3. Dataset titles that include port identifiers

If filenames encode both conventions, cross-check consistency:

```text
p13_NN → port 1 → port 3 labeled NN → port 1 = N_in, port 3 = N_out
p14_PN → port 1 → port 4 labeled PN → port 1 = N_in, port 4 = P_out
p23_NP → port 2 → port 3 labeled NP → port 2 = P_in, port 3 = N_out
p24_PP → port 2 → port 4 labeled PP → port 2 = P_in, port 4 = P_out
→ Port 1=N_in, Port 2=P_in, Port 3=N_out, Port 4=P_out, [output][input] labels
```

If all four agree, present that mapping and ask for one confirmation.
If they contradict or nothing is encoded, ask only what is still unclear:

1. PORT ROLES — which physical terminal is on each VNA port?
2. FILE NAMING — which parameter identifies the pair?
3. LABEL ORDER — `[output][input]` or `[input][output]`?
   - `[output][input]`: `PN` = N_input → P_output
   - `[input][output]`: `PN` = P_input → N_output

Do not proceed without confirmed port assignments.

### 2. What to report

Ask what they want: SDD21 only, SDD21+SCC21 (CMRR), or all four
(SDD21, SCC21, SDC21, SCD21).

## Port naming

### A — Port-pair numbers

Files named `p{stimulus}{response}`. Map through the port-role table.

Example (Port 1=N_in, 2=P_in, 3=N_out, 4=P_out), `[output][input]`:

| File | VNA | Polarity | Variable |
|-|-|-|-|
| p13 | 1 → 3 | NN | S_NN |
| p14 | 1 → 4 | PN | S_PN |
| p23 | 2 → 3 | NP | S_NP |
| p24 | 2 → 4 | PP | S_PP |

### B — Polarity `[output][input]`

First letter = output polarity. `PN` = P_out, N_in.

### C — Polarity `[input][output]`

First letter = input polarity. `PN` means the opposite path from B.
**This is the usual mix-up.** Always confirm.

## Simonovich / Bockelman numbering

```text
Port 1 = Positive input (+)
Port 2 = Negative input (−)
Port 3 = Positive output (+)
Port 4 = Negative output (−)
```

Sij = from port j to port i. With `[output][input]` polarity:

- S31 = PP
- S32 = PN
- S41 = NP
- S42 = NN

## Formulas (complex linear)

Convert to dB **only at the end**. Prefactor `0.5` is required.
PP, PN, NP, NN are complex S21 of each 2-port file.

```text
SDD21 = 0.5 × (PP − PN − NP + NN)
SCC21 = 0.5 × (PP + PN + NP + NN)
SDC21 = 0.5 × (PP − PN + NP − NN)
SCD21 = 0.5 × (PP + PN − NP − NN)
```

Reflection (SDD11, …) from four 2-port S11 values is an **approximation**
(each S11 was measured with a different port-2 termination). Prefer a
full S4P for reflection. Same 0.5 combinations on S11_PP/PN/NP/NN.

Some legacy scripts invert signs (`0.5 × (PN − PP − NN + NP)`). Magnitude
in dB can still look right; **phase is wrong**. Use the formulas above.

## CloudSprite (this plugin)

1. `set_scope` to the team/project that holds the four files.
2. `search_datasets` + `get_dataset` to identify the four sources and
   confirm mapping (filenames, parameters).
3. `get_trace_summary` for x-range / point count — check the four files
   share a grid before combining.
4. Raw S21 samples are **not** returned by MCP. If the user needs the
   actual conversion, they run it locally (scikit-rf, their files or SDK)
   with **their** credentials — never a token from this plugin.
5. Do not `POST` datasets or notebooks. Say that publishing mixed-mode
   results through the assistant is not in this release; they can upload
   from the CloudSprite app.

## Touchstone reminders

- scikit-rf: `network.s[f, 1, 0]` is S21 (0-based)
- 50 Ω single-ended ↔ 100 Ω differential is the usual VNA/Touchstone
  convention
- Upload format in the product is `.s2p`, not `.s1p` / CSV, when they
  publish later from the app

## Common mistakes

| Mistake | Fix |
|-|-|
| Computing before port roles are confirmed | Always confirm — wrong mapping looks plausible |
| Arithmetic on dB | Formulas are **complex linear** |
| Dropping the 0.5 | Every mixed-mode formula has it |
| Assuming `[out][in]` vs `[in][out]` | `PN` can mean opposite paths |
| Presenting 2-port SDD11 as exact | Call it an approximation; recommend S4P |
