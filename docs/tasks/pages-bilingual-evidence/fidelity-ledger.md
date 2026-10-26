# Bilingual Pages visual fidelity ledger

The deployed Chinese page at the task base commit is the visual baseline. Both locale pages retain its centered shell, cards, sidebar, amber download action, typography, spacing, and responsive stacking. Screenshots below were captured from the local site mounted at `/octopath-traveler-1_autoresolve/`.

| Comparison | Observation | Decision |
| --- | --- | --- |
| Shared palette and surfaces | English and Chinese screenshots at 1440px retain the same blue-gray canvas, white cards, fine borders, soft shadows, and amber download panel. | Reused the existing CSS tokens and layout without a redesign. |
| Desktop hierarchy | At 1440px both languages retain the side-by-side hero and article/sidebar columns. | Kept the established hierarchy and section ordering. |
| Longer English headings and copy | English wraps within the existing cards; headings, settings rows, and download metadata remain inside their surfaces. | Used the existing wrapping and responsive grid rules; no clipped text observed. |
| Top-right language control | The English/中文 control is present beside project links and download on desktop, with the current language underlined and marked `aria-current="page"`. | Kept both language choices visible, including when mobile hides secondary project links. |
| Narrow 320px header | Both language links remain visible; the download action wraps below when needed instead of competing for the same row. | Added only a narrow-width wrap rule; no horizontal page overflow observed. |
| Mobile content and navigation | Both locale pages stack the hero and article, preserve the native mobile TOC, and keep FAQ disclosures usable. | Retained native `<details>` and shared mobile layout. |
| Content and metadata parity | Section IDs, code/config values, release targets, and facts are aligned. Titles, descriptions, canonical URLs, and Open Graph URLs are localized per route. | Used two static documents so direct loads work without a script or browser-locale inference. |

Screenshots: `en-desktop-1440.png`, `en-mobile-390.png`, `en-mobile-320.png`, `zh-desktop-1440.png`, `zh-mobile-390.png`, and `zh-mobile-320.png`.
