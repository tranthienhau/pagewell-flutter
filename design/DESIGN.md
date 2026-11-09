# Pagewell Design System

Bright, modern mobile app for reading ebooks, listening to audiobooks, searching a reference library and reading a daily editorial piece. Calm, literary, premium. Light theme.

## Color (use ONLY these colors; no default violet or indigo, no flat neutral grey)
- Background: #FAF4FC (tinted near-white)
- Surface (cards, sheets): #FFFFFF; Surface alt (grouped rows): #F3E8F6
- Accent (bright orchid, large fills, icons, active states, big numerals): #C64BE0
- Accent fill (any button or chip with a WHITE label, links, chip text): #A337BA; pressed #9B3BAF
- Accent tint (selected states, chip fills): #F6E4FA
- Support (decoration, illustration accents): #A8D672; support strong (data, progress second series): #6EA22E
- Text primary #1C0C1F, secondary #574A5A, tertiary #76687A
- Hairline divider #EADCEE; input and control borders #B085B4
- Status (text on tint): success #0E7C3A on #E3F4E9, warning #A75906 on #FAEFE1, danger #CE2020 on #FBE5E5, info #A337BA on #F4E7F7
- Hero gradient (any surface carrying white text): #A337BA -> #9B3BAF. The soft accent -> support blend (#C64BE0 -> #A8D672) is decoration only, never behind text.
- Premium badge: ink #1C0C1F pill with white text.

## Typography
- Family: Outfit for all UI and body text. Fraunces (serif) for display titles, book titles in heroes and the reader body text.
- Display 32 / 700 / -0.02em (screen titles, hero titles)
- Title 20 / 600 (section headers, card titles)
- Body 16 / 400 (reader text may use Fraunces 18 with 1.6 line height)
- Label 14 / 500 (buttons, tabs)
- Caption 13 / 500 (metadata, secondary color)
- Use only these sizes. Minimum text 12px (13px chips and tags, 14px legal text).

## Frame and layout
- 393x852 mobile frame. Keep top ~59px (status bar) and bottom ~34px (home indicator) clear of tappable content.
- 8pt spacing (4, 8, 12, 16, 24, 32), screen edge padding 20px, generous vertical rhythm.
- Radius: card 20, control 14, input 12, pill 999. Book covers 12px radius, 2:3 ratio, soft shadow.
- Elevation: soft only, card = 0 1px 2px rgba(28,12,31,.04) + 0 8px 24px rgba(28,12,31,.06). No hard or black shadows.
- Icons: one set only, Lucide-style rounded outline, 24px, 1.75 stroke. Do not mix filled and outline.

## Controls (one spec each, reused on every screen)
- Primary button: pill, 56px tall, fill #A337BA, white 14/500 label; pressed #9B3BAF; disabled 40% opacity.
- Secondary button: pill, white fill, 1.5px #B085B4 border, ink label.
- Text input: 12px radius, 52px tall, white, 1px #B085B4 border; focus = 2px #A337BA ring; error = #CE2020 border + 13px helper.
- Card: white, 20px radius, soft shadow.
- Chip: pill, 32px tall, #F6E4FA fill, #A337BA 13px label. Chips on a gradient use a dark translucent fill with white text, never white fill.
- Segmented control: #F3E8F6 track, white selected segment with ink label.
- Progress bar: 6px pill track #F3E8F6, fill #C64BE0.
- Mini player: white card pinned above the tab bar: small cover, title + author, play button in #A337BA.

## Shared components
- Bottom tab bar (exactly 5 tabs, this order): Today (sun icon), Library (library icon), Search (search icon), Saved (bookmark icon), Profile (user icon). Flat white bar, 1px #EADCEE top border, no gradient. Active tab: icon + label in #A337BA with a small #F6E4FA pill behind the icon. Inactive: #574A5A. Never rename, reorder, add or remove tabs.
- Header: screen title left in Fraunces display style; small round avatar right.
- Detail screens (book, reader, player, article, reference entry, membership, editor studio) are full-screen with a back or close control and no tab bar.

## Focal element
One bold focal element per screen (today's read hero card, big book cover, big play button, plan card). Everything else stays quiet.

## Imagery
Real photography only (book covers are photographic cover art with the title set in type); empty states and onboarding also use real photos or flat 2D vector art. NO 3D renders, claymorphism, isometric, CGI or glossy plastic objects.

## Meaning of color
Red only for errors and destructive actions (Sign out). Warnings use the warning color with an icon.

## Copy scope
Do not mention: AI narrator, Podcast, Social feed, Comments, NFT, Live audio. No invented integrations or person names beyond Ava Morgan, Imogen Hale, Theo Marsh, Clara Bennett, Lena Ortiz.
