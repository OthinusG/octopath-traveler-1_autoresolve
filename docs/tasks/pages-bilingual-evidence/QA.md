# Bilingual Pages verification

Base path tested: `/octopath-traveler-1_autoresolve/`, served locally with Microsoft Edge headless and browser locale `zh-CN`.

- Root route loads the English HTML (`lang="en"`) even with a Chinese browser locale. Direct `zh.html` navigation and reload remain `zh-CN`.
- The visible language links work in both directions; both routes also render with JavaScript disabled.
- At 1440, 390, and 320 CSS pixels in both locales, the language switch and download control remain visible. No page-level horizontal overflow, broken section links, failed local requests, or browser exceptions were observed.
- Keyboard Tab focus is visible (solid 3px outline). The mobile table of contents opens and navigates to the selected section; the FAQ disclosure opens.
- `assets/site.css` and `assets/favicon.svg` returned HTTP 200 under the project prefix. Local HTML routes returned HTTP 200.
- A focused HTML check passed for localized document/canonical/Open Graph metadata, `en`/`zh-CN`/`x-default` alternates, matching section IDs and code values, identical external links, local assets, valid section fragments, and English-page copy (with only the intended `中文` switch label in Chinese).
- Existing mod verification passed: `lua tests/test_mod.lua "$PWD"` (49 cases) and `python3 tools/package_mod.py`. `git diff --check` passed.

Full browser measurements and interactions: `browser-report.json`. Screenshots: `en-desktop-1440.png`, `en-mobile-390.png`, `en-mobile-320.png`, `zh-desktop-1440.png`, `zh-mobile-390.png`, `zh-mobile-320.png`. Visual comparisons and decisions: `fidelity-ledger.md`.

No in-game retest or deployment was performed; this change only updates static product documentation.

## Issuer review and public deployment

Issuer code/content/visual review accepted the branch and independently reran 49 Lua tests, packaging and diff checks. Pages deployment [40291848482](https://github.com/OthinusG/octopath-traveler-1_autoresolve/actions/runs/40291848482) and existing Mod CI passed. Public root English, zh.html and shared CSS returned HTTP 200 and exactly matched reviewed source. Public Edge checks with zh-CN locale passed both languages at 1440/390/320px, visible language/download controls, section anchors, direct/reload Chinese, switching both directions and no-JS rendering; there were no browser exceptions or failed requests.
