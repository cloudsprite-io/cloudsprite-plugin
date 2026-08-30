# Grok marketplace PR (do not open until the promote gate is green)

Fork https://github.com/xai-org/plugin-marketplace, branch from `main`, add
**one** remote entry (do not vendor files under `external_plugins/`).

## Pin

`source.sha` must be the full 40-char commit of `cloudsprite-io/cloudsprite-plugin`
`main`. Packet authoring pin (update after listings merge):

`b65c2874e35630deab32045dc2f23a117fa4533a`

```text
git ls-remote https://github.com/cloudsprite-io/cloudsprite-plugin.git refs/heads/main
```

Paste the object from [grok-marketplace-entry.json](grok-marketplace-entry.json)
into `.grok-plugin/marketplace.json` (or the catalog path that repo uses on
`main` at submit time). Then:

```text
python3 scripts/generate-plugin-index.py
python3 scripts/validate-catalog.py
python3 scripts/generate-plugin-index.py --check
```

PR title: `Add CloudSprite plugin (remote SHA pin)`

Do not use a personal-account `source.url`. Do not pin `main` or tag `v0.1.3`
as the SHA — pin the commit.

Before opening: confirm Grok token-storage parity (Claude stores OAuth natively;
Grok behavior still unverified per api#303).
