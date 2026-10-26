# OT1 Auto Resolve Website PRD

## Product

A Chinese-first product detail and documentation page for the unofficial Octopath Traveler I Auto Resolve mod. The audience is Windows players who need to decide whether the mod fits their game, install the required loader and mod, configure it safely, and diagnose common issues.

## Goal and user path

Help a player answer, in order: what the mod does; whether the game and loader versions match; which encounters and rewards it covers; how to download and install it; how to change settings, upgrade, uninstall, and troubleshoot.

The primary action downloads the published v0.1.3 mod-only ZIP. The release page, checksum, repository source, validation record, and UE4SS loader page are secondary links.

## Content and hierarchy

1. Compact site header and breadcrumb.
2. Product detail hero: title, concise benefit, version/status/compatibility labels, and a prominent working ZIP link with release and checksum links.
3. Main article: behavior and eligibility; rewards and exclusions; installation; configuration; upgrade/uninstall; validation scope; FAQ/troubleshooting; source and support links.
4. Desktop side column: quick compatibility facts and in-page section navigation. Mobile moves navigation into a native disclosure and stacks the content.

Use fixed, source-grounded v0.1.3 content from `README.md`, `mod/README.md`, `docs/VALIDATION.md`, and the published release. Preserve the distinction between the mod-only release ZIP and the source archive. Do not claim unverified gameplay outcomes or an independently selected license.

## Visual source and product constraints

The authoritative reference is the rendered mod detail page at <https://www.xxexpand.com/g/palworld/mods/stack-light?pageSize=24>, inspected in Edge at 1440px and 390px and as a tall full-page render on 2026-10-26. The page uses a centered roughly 1052px container, a pale blue-gray canvas, white rounded cards with fine borders and soft shadows, dark system sans-serif text, restrained gray metadata, and warm amber for primary download actions. Its desktop detail page places the main visual and metadata/download panel side by side, then uses a wider article column and narrower sidebar. The reference's mobile view clips horizontally; this page keeps its detail hierarchy while correcting that behavior.

No game image, logo, font, or unrelated artwork is available or authorized for reuse. Use native text and CSS surfaces only. Simplify away global marketplace navigation/search, user accounts, author/profile, pricing, ratings/download counters, comments, advertisements, and unrelated recommendations. Retain only product metadata, real download links, readable detail sections, and compact section navigation.

## Acceptance criteria

- Hosted at `https://othinusg.github.io/octopath-traveler-1_autoresolve/`; relative asset paths work under the repository subpath.
- Native static HTML/CSS with only minimal JavaScript if a necessary interaction cannot use platform HTML.
- Required v0.1.3 behavior, compatibility, install/upgrade, settings, troubleshooting, and validation facts are accurate and linked to project sources.
- No dead controls, placeholders, game artwork, fabricated usage data, private paths, or secrets.
- Desktop and mobile layouts have no clipping or overlap. Check 1440px, 390px, and 320px; long paths/code may scroll inside their own blocks.
- Keyboard focus is visible, headings and links are meaningful, and any mobile navigation remains keyboard accessible.
- A fidelity ledger records at least five reference-to-render comparisons and fixes/deviations, with reference and implementation screenshots stored outside the deployed artifact.
- Existing Lua and package checks pass; local browser QA checks assets, links, anchors, errors, overflow, and responsive layouts.
- A reviewable Pages workflow deploys `docs/site` from the existing repository after changes reach `main`; no deployment is run before issuer review and integration.

## Delivery tasks

1. Lock the reference and document fixed v0.1.3 content, visual tokens, project path, and acceptance checks.
2. Build the single static page and Pages workflow with no mod logic changes.
3. Render the page at the real project prefix, inspect screenshots at all target widths, and record the fidelity ledger.
4. Run the existing Lua/package checks and verify published release links and archive layout.
5. Submit the isolated branch and evidence for issuer review; integration and first deployment follow that review.

## Risks and constraints

The site must not imply that UE4SS is bundled or that the mod has a license it does not have. Validation copy must distinguish portable tests and native interface checks from incomplete in-game scenarios. GitHub Pages configuration and publishing permissions are external repository state and are left for post-review integration by the issuer.
