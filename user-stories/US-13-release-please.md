# US-13 — Release Please voor automated releases

| Veld | Waarde |
|---|---|
| ID | US-13 |
| Titel | Release Please GitHub Action configuratie |
| Rol | Developer |
| Afhankelijk van | US-12 |
| Status | **Klaar** |
| Datum voltooid | 2025-09-16 |
| Prioriteit | **P2 — Medium** |
| Geschatte effort | 45 minuten |

## Verhaal

Als developer wil ik geautomatiseerde releases en changelogs via release-please, zodat ik geen handmatige release management taken hoef uit te voeren en consistent versiebeheer heb volgens Conventional Commits.

## Doel

Configureer release-please GitHub Action voor:
1. Automatische versioning op basis van commit messages
2. Changelog generatie
3. GitHub release creatie
4. Git tag aanmaak

## Acceptatiecriteria

- [ ] `.github/workflows/release-please.yml` aangemaakt
- [ ] `.github/workflows/release-please-manifest.yml` voor multi-package (optioneel)
- [ ] `.release-please-manifest.json` geconfigureerd
- [ ] `release-please-config.json` met conventionele commit instellingen
- [ ] README bijgewerkt met release workflow informatie
- [ ] Test release getriggerd
- [ ] Git commit gemaakt

## Release Please Configuratie

### Conventional Commits Formaat

release-please gebruikt Conventional Commits voor versioning:

```
feat: nieuwe feature → MINOR version (1.1.0)
fix: bugfix → PATCH version (1.0.1)
feat!: breaking change → MAJOR version (2.0.0)
```

### Voorbeeld Commit Messages

```bash
# Feature (MINOR)
feat(dashboards): voeg KPI panels toe aan overview
feat(alerts): voeg data exfiltration detection toe

# Fix (PATCH)
fix(makefile): gebruik .spl extensie in plaats van .splunk
fix(dashboards): voeg version="1.1" toe aan alle dashboards

# Breaking Change (MAJOR)
feat!: herschrijf dashboard architectuur
feat(alerts)!: verwijder verouderde detection rules

# Docs (geen version impact)
docs(lookups): voeg LOOKUPS.md toe
docs(readme): update installation instructions
```

## Implementatie Stappen

### 1. GitHub Workflow Aanmaken

Creëer `.github/workflows/release-please.yml`:

```yaml
name: release-please

on:
  push:
    branches:
      - main

permissions:
  contents: write
  pull-requests: write

jobs:
  release-please:
    runs-on: ubuntu-latest
    steps:
      - uses: googleapis/release-please-action@v4
        id: release
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          target-branch: main
          
      # Optioneel: Build en upload .spl package bij release
      - name: Checkout code
        if: ${{ steps.release.outputs.release_created }}
        uses: actions/checkout@v4
        
      - name: Build Splunk package
        if: ${{ steps.release.outputs.release_created }}
        run: make build
        
      - name: Upload .spl to release
        if: ${{ steps.release.outputs.release_created }}
        uses: svenstaro/upload-release-action@v2
        with:
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          file: SOC-Analyst.spl
          asset_name: SOC-Analyst-${{ steps.release.outputs.tag_name }}.spl
          tag: ${{ steps.release.outputs.tag_name }}
          overwrite: true
```

### 2. Release Please Config

Creëer `release-please-config.json`:

```json
{
  "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json",
  "release-type": "simple",
  "packages": {
    ".": {
      "changelog-path": "docs/CHANGELOG.md",
      "bump-minor-pre-major": false,
      "bump-patch-for-minor-pre-major": false,
      "draft": false,
      "prerelease": false,
      "include-component-in-tag": false,
      "include-v-in-tag": true,
      "tag-name": "v${version}",
      "release-name": "v${version}",
      "extra-files": [
        "README.md",
        "docs/CHANGELOG.md"
      ]
    }
  },
  "changelog-sections": [
    {"type": "feat", "section": "Features", "hidden": false},
    {"type": "fix", "section": "Bug Fixes", "hidden": false},
    {"type": "docs", "section": "Documentation", "hidden": false},
    {"type": "perf", "section": "Performance Improvements", "hidden": false},
    {"type": "refactor", "section": "Code Refactoring", "hidden": false},
    {"type": "test", "section": "Tests", "hidden": false},
    {"type": "build", "section": "Build System", "hidden": false},
    {"type": "ci", "section": "Continuous Integration", "hidden": false},
    {"type": "chore", "section": "Chores", "hidden": true}
  ]
}
```

### 3. Manifest File

Creëer `.release-please-manifest.json`:

```json
{
  ".": "1.1.0"
}
```

### 4. GitHub Secrets (optioneel)

Voor geautomatiseerde .spl upload zijn geen extra secrets nodig — `GITHUB_TOKEN` werkt prima.

Als je naar Splunk Cloud wilt deployen:
- `SPLUNK_CLOUD_API_KEY`: API key voor Splunk Cloud
- `SPLUNK_CLOUD_APP_ID`: App ID in Splunk Cloud

## Testing

### Test Release Triggeren

```bash
# Maak een test commit
git commit -m "test: trigger release-please workflow"

# Push naar main
git push origin main

# Check GitHub Actions tab
# https://github.com/JOUW_USERNAME/SOC-Analyst/actions
```

### Verwachte Output

1. **Pull Request aangemaakt:** "chore(main): release 1.2.0"
2. **Bij merge:** Release wordt gecreëerd
3. **Changelog:** Bijgewerkt in `docs/CHANGELOG.md`
4. **Git tag:** `v1.2.0` aangemaakt
5. **GitHub Release:** Met .spl package als asset

## Definition of Done

- [ ] release-please workflow geconfigureerd
- [ ] Eerste release succesvol gemaakt
- [ ] Changelog automatisch gegenereerd
- [ ] .spl package uploaded naar release
- [ ] README bijgewerkt met release info
- [ ] Git commits gemaakt

## Resources

- [release-please GitHub Action](https://github.com/googleapis/release-please-action)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [release-please config schema](https://github.com/googleapis/release-please/blob/main/schemas/config.json)
