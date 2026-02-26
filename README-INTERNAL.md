# CodexBar Fork - Internal Build and Contributor Guide

## 1-Minute Guide

Choose one path:

### A) Build from source (recommended for contributors)
```bash
git clone https://github.com/alexcol23/CodexBar.git
cd CodexBar
xed .
```

In Xcode:
- Scheme: `CodexBar`
- Destination: `My Mac`
- Run: `⌘R`

### B) Install internal binary (fastest for non-dev users)
1. Download internal ZIP from your team share.
2. Unzip and move `CodexBar.app` to `/Applications`.
3. Open app (if blocked: right-click -> Open once).

If needed:
```bash
xattr -dr com.apple.quarantine /Applications/CodexBar.app
open /Applications/CodexBar.app
```

### Configure LiteLLM (required)
Create/update `~/.codexbar/config.json`:
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

Then relaunch CodexBar and enable LiteLLM in Settings -> Providers.

## Overview
This repository is an internal fork of [steipete/CodexBar](https://github.com/steipete/CodexBar) (MIT licensed) with team-specific changes (including LiteLLM provider work).

Current distribution model:
- Build from source on macOS
- Optional internal ad-hoc binary ZIP (click-to-open install path)
- Share changes through fork branches + pull requests

## Prerequisites
- macOS 14+
- Full Xcode installed (not only Command Line Tools)
- GitHub account with access to the fork

Check Xcode path:

```bash
xcode-select -p
```

Expected path should point to full Xcode, for example:

```text
/Applications/Xcode.app/Contents/Developer
```

If needed:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

## Quick Start (Build and Run)
1. Fork `steipete/CodexBar` using GitHub UI (top-right "Fork" button).
2. Clone your fork locally:

```bash
git clone git@github.com:<YOUR_ORG_OR_USER>/CodexBar.git
cd CodexBar
```

3. Add upstream remote:

```bash
git remote add upstream https://github.com/steipete/CodexBar.git
git remote -v
```

4. Fetch latest refs:

```bash
git fetch --all --prune
```

5. Open in Xcode (Swift Package workflow):

```bash
xed .
```

6. In Xcode, select scheme and destination:
- Scheme: `CodexBar`
- Destination: `My Mac`

7. Build and run:
- Press `⌘R`

8. Verify app launch:
- CodexBar appears in the macOS menu bar (top-right status area)

9. Quit app:
- From menu bar: `Quit CodexBar`
- Or terminal fallback:

```bash
pkill -x CodexBar || true
```

10. Logs:
- Console.app filter: `subsystem: com.steipete.codexbar`
- Live stream from terminal:

```bash
log stream --style compact --predicate 'subsystem == "com.steipete.codexbar"'
```

- Optional file log (when enabled in Debug settings):

```text
~/Library/Logs/CodexBar/CodexBar.log
```

## Optional: Internal Ad-hoc Binary Distribution
Use this when teammates prefer installing an app bundle instead of building from source.

### Maintainer: build ad-hoc ZIP artifact
From repo root:

```bash
./Scripts/build_internal_adhoc_release.sh
```

Artifact output:

```text
dist/internal/CodexBar-internal-adhoc-v<VERSION>-b<BUILD>-<COMMIT>.zip
```

Share that ZIP internally (Slack/Drive/GitHub Release in your fork).

### Teammate: install by clicking app
1. Download and unzip the internal ZIP.
2. Move `CodexBar.app` to `/Applications` (or keep in user apps folder).
3. Open `CodexBar.app` by double-click.
4. If macOS blocks first launch:
   - Right-click app -> Open
   - If needed:

```bash
xattr -dr com.apple.quarantine /Applications/CodexBar.app
open /Applications/CodexBar.app
```

Notes:
- Ad-hoc binaries are intended for internal use/testing.
- Auto-update and notarization are not part of this ad-hoc flow.

## Configuration (No Secrets in Git)
Never commit API keys or cookies to the repository.

Preferred config location:

```text
~/.codexbar/config.json
```

### Example `config.json` snippet (LiteLLM)
Use placeholders only:

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

Notes:
- Keep existing provider entries; add/update the `litellm` entry.
- File is local-only and should remain private.

### Alternative: Environment Variables
For GUI apps on macOS, use `launchctl setenv` (shell exports alone are often not visible to GUI apps):

```bash
launchctl setenv LITELLM_API_KEY "<LITELLM_KEY>"
launchctl setenv LITELLM_BASE_URL "https://fern.addi.com"
```

Unset when needed:

```bash
launchctl unsetenv LITELLM_API_KEY
launchctl unsetenv LITELLM_BASE_URL
```

### Verify Config Is Being Read
- In CodexBar Settings -> Providers:
  - `LiteLLM` is visible and enabled
  - API source mode is active (or equivalent source label)
- In menu bar UI:
  - LiteLLM usage card/bar is visible and updates
- In logs:

```bash
log stream --style compact --predicate 'subsystem == "com.steipete.codexbar"'
```

If configuration is missing, you may see provider fetch errors (for example, no available strategy or missing token).

## Development Workflow (Fork + Branch + PR)

### 1) Create feature branch

```bash
git checkout main
git fetch upstream
git rebase upstream/main
# or: git merge --ff-only upstream/main
git push origin main

git checkout -b feat/litellm-provider
```

### 2) Commit and push branch

```bash
git add .
git commit -m "feat: add LiteLLM provider support"
git push -u origin feat/litellm-provider
```

### 3) Open PR
Options:
- Internal review PR: `fork/feat/litellm-provider -> fork/main`
- Upstream PR (if appropriate): `fork/feat/litellm-provider -> steipete/main`

### 4) Keep branch updated (recommended: rebase)

```bash
git fetch upstream
git checkout main
git rebase upstream/main
git push origin main

git checkout feat/litellm-provider
git rebase main
git push --force-with-lease
```

Merge-based alternative:

```bash
git fetch upstream
git checkout main
git merge --ff-only upstream/main
git push origin main

git checkout feat/litellm-provider
git merge main
git push
```

## Troubleshooting

### 1) Gatekeeper / permissions
If you run a downloaded app bundle and macOS blocks it:
- Right-click app -> Open
- Or remove quarantine attribute:

```bash
xattr -dr com.apple.quarantine /path/to/CodexBar.app
```

(Usually not needed when running directly from Xcode.)

### 2) "No available fetch strategy" or missing usage
Likely causes:
- Provider enabled but missing required token/config
- Wrong provider source mode selected
- GUI app does not see shell env vars

Fix:
- Set key in `~/.codexbar/config.json` OR via `launchctl setenv`
- Confirm provider source in Settings -> Providers
- Relaunch CodexBar after env changes

### 3) Xcode scheme missing / wrong scheme
- Ensure workspace opened from repo root with `xed .`
- Select scheme `CodexBar`
- Select destination `My Mac`

### 4) App not showing in menu bar
- Verify app is running (`pgrep -x CodexBar`)
- Confirm at least one provider is enabled
- Quit and rerun from Xcode (`⌘R`)

### 5) Reset local app config
Backup then reset:

```bash
mv ~/.codexbar ~/.codexbar.backup.$(date +%Y%m%d-%H%M%S)
```

App will recreate fresh config on next launch.

### 6) Reset repository changes
Danger: removes uncommitted local edits.

```bash
git checkout .
git clean -fd
```

## Attribution and License
- Upstream project: [steipete/CodexBar](https://github.com/steipete/CodexBar)
- License: MIT
- Keep the upstream `LICENSE` file in this fork.
- Preserve attribution in docs and PR descriptions when contributing upstream.
