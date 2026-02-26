# CodexBar Internal Guide

## 1-Minute Setup (Teammates)
If you only want to run the app, follow this and stop.

### Option A: Build from source
```bash
git clone https://github.com/alexcol23/CodexBar.git
cd CodexBar
xed .
```

In Xcode:
- Scheme: `CodexBar`
- Destination: `My Mac`
- Run: `⌘R`

### Option B: Install internal app ZIP
1. Download the internal ZIP from team share.
2. Unzip and move `CodexBar.app` to `/Applications`.
3. Open the app.
4. If macOS blocks first launch, right-click -> Open once.

If still blocked:
```bash
xattr -dr com.apple.quarantine /Applications/CodexBar.app
open /Applications/CodexBar.app
```

## Download Internal Release
Latest internal release page:
- https://github.com/alexcol23/CodexBar/releases/tag/internal-2026-02-26-ba78fea

All releases:
- https://github.com/alexcol23/CodexBar/releases

Download these two assets:
1. `CodexBar-internal-adhoc-...zip`
2. `CodexBar-internal-adhoc-...zip.sha256`

Verify checksum:
```bash
shasum -a 256 CodexBar-internal-adhoc-...zip
cat CodexBar-internal-adhoc-...zip.sha256
```

## Required LiteLLM Config
Create/update `~/.codexbar/config.json` (never commit secrets):

```json
{
  "version": 1,
  "providers": [
    {
      "id": "litellm",
      "enabled": true,
      "source": "api",
      "apiKey": "<LITELLM_KEY>",
      "region": "https://fern.addi.com"
    }
  ]
}
```

Then relaunch CodexBar and enable `LiteLLM` in Settings -> Providers.

## Quick Verify
- Menu bar icon appears after launch.
- LiteLLM provider appears in Settings.
- Usage card updates after refresh.

Optional logs:
```bash
log stream --style compact --predicate 'subsystem == "com.steipete.codexbar"'
```

---

## Maintainer Appendix (Internal Distribution)

### Build internal ad-hoc ZIP
```bash
./Scripts/build_internal_adhoc_release.sh
```

Output artifact:
```text
dist/internal/CodexBar-internal-adhoc-v<VERSION>-b<BUILD>-<COMMIT>.zip
```

Share that ZIP internally.

### What this script does
1. Builds `CodexBar.app`.
2. Applies ad-hoc signing.
3. Verifies signature.
4. Packages ZIP for click-to-open install.
5. Prints SHA256.

### Contributor workflow (short)
```bash
# keep local main up to date
git checkout main
git fetch upstream
git rebase upstream/main
git push origin main

# feature work
git checkout -b feat/<feature-name>
git add .
git commit -m "feat: ..."
git push -u origin feat/<feature-name>
```

Open PR to your fork `main` for internal review.

## Troubleshooting
- App not visible in menu bar:
  - Ensure process is running: `pgrep -x CodexBar`
  - Ensure at least one provider is enabled.
- Missing usage / fetch strategy errors:
  - Check `~/.codexbar/config.json` has LiteLLM `apiKey`.
  - Relaunch app after config/env changes.
- Wrong Xcode target:
  - Select scheme `CodexBar` and destination `My Mac`.
- Reset app config:
```bash
mv ~/.codexbar ~/.codexbar.backup.$(date +%Y%m%d-%H%M%S)
```
- Reset local repo (danger: deletes uncommitted changes):
```bash
git checkout .
git clean -fd
```

## Attribution and License
- Upstream: https://github.com/steipete/CodexBar
- License: MIT (keep `LICENSE` file in this fork)
