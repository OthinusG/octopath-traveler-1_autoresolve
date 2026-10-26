# OT1 Auto Resolve Website Technical Specification

## Runtime and hosting

- Static site root: `docs/site/`; no build system, framework, runtime API, analytics, or added dependency.
- Host: GitHub Pages project site at `https://othinusg.github.io/octopath-traveler-1_autoresolve/`.
- Use document-relative links for local assets and anchors. Canonical and Open Graph URLs include the project base path. Never use root-relative local assets.
- `docs/site/` is the only Pages artifact. QA screenshots and the fidelity ledger remain under `docs/tasks/pages-website-evidence/`.

## Page structure

One semantic HTML page: header, breadcrumb, product hero, article with anchored sections, desktop compatibility/navigation aside, and small footer. A native `<details>` disclosure presents the section links on mobile. No client-side data fetching or content integration is required; version and release facts are fixed to v0.1.3.

The ZIP anchor targets the published mod-only release asset. Adjacent links target the release notes and SHA-256 sidecar. Installation distinguishes the release archive layout (`Win64/Mods/OT1AutoResolve`) from source checkout layout. FAQ uses native `<details>/<summary>`.

## Visual tokens and responsive behavior

Tokens are derived from the rendered reference selected in `docs/PRD.md`: centered 1052px maximum content width; pale blue-gray page background; white card surfaces; dark charcoal text; muted gray metadata; amber primary action; subtle cool borders and shadows; system sans-serif typography. Rounded card corners are approximately 10–12px. The desktop hero uses a text-and-download two-column composition rather than borrowing the reference game's artwork. Below, the article and compact fact/navigation aside use an approximately 2.3:1 column ratio.

At tablet/mobile widths, the hero and article stack, the sidebar facts follow the primary article, and a native disclosure replaces desktop section navigation. The header wraps or hides secondary navigation behind that disclosure instead of overflowing. Code and long paths can scroll within their own blocks. No sticky element may cover anchor targets or the download action. Respect `prefers-reduced-motion`; keep movement minimal.

## Content source of truth

Version, target, behavior, install, config, known exclusions, and test boundaries come from repository README files and `docs/VALIDATION.md`. Release ZIP, checksum, and UE4SS links were checked over HTTP on 2026-10-26. No gameplay claim exceeds the documented evidence. Keep the unofficial status and absent standalone mod license explicit.

## GitHub Pages workflow

Use a single workflow with `workflow_dispatch` and pushes to `main` when `docs/site/**` or the Pages workflow changes. The deploy job only runs from `main`, including manual dispatches. Give `contents: read`, `pages: write`, and `id-token: write`; set `github-pages` environment and one `github-pages` concurrency group; configure Pages, upload only `docs/site`, and deploy with official Pages actions pinned to full commit SHAs: checkout v4.2.2 (`11bd71901bbe5b1630ceea73d27597364c9af683`), configure-pages v6.0.0 (`45bfe0192ca1faeb007ade9deae92b16b8254a0d`), upload-pages-artifact v5.0.0 (`fc324d3547104276b827a68afc52ff2a11cc49c9`), and deploy-pages v4.0.5 (`d6db90164ac5ed86f2b6aed7e0febac5b3c0c03e`). Do not modify the existing mod validation workflow or package contents. Initial integration and the first deployment happen only after issuer review.

## Risks and verification

- The site path contains the repository name; canonical/social URLs and links must keep that path.
- Release assets could disappear or move; verify the real ZIP and checksum before handoff.
- Pages may be unconfigured or the token may lack permission. The issuer inspects existing configuration, enables workflow-based Pages if needed, integrates the reviewed branch, then verifies the public response.
- Run existing Lua and packaging checks despite no mod changes. Serve locally under `/octopath-traveler-1_autoresolve/` and inspect at 1440, 390, and 320px. Verify all local resources, external primary links, anchors, browser console, overflow, and navigation. Validate workflow YAML with an installed parser if available; otherwise review its structure and expressions directly.
- Do not report the website deployed or claim broader in-game acceptance.
