# Website branding verification

The user-provided OCTOPATH TRAVELER icon replaces the placeholder header mark and favicon in both locales, and appears above the localized Mod title. The mobile-game subtitle is removed; localized product text and unofficial status remain selectable and intact.

- Both languages reviewed at 1440, 390 and 320px in Edge; language and download controls remain visible, with no page overflow or broken section anchors.
- English/Chinese links, direct Chinese load/reload and no-JavaScript rendering pass.
- Shared PNG asset has fixed intrinsic dimensions; CSS contains it proportionally. Header wordmark text is hidden on narrow viewports to retain room for language and download controls.
- Existing 49 Lua tests, packaging and diff checks pass. No Mod logic changes or in-game retest.
