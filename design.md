# design.md - Design System & UI Specs for "Monthly"

## 1. Visual Theme & Philosophy
- **Vibe:** Calm, reassuring, modern, non-clinical, private, and stigma-free.
- **Form Language:** Generously rounded corners (radius: 16px - 28px), soft pastel pills, elevated neutral cards with ultra-soft ambient drop-shadows.

---

## 2. Color Palette & Design Tokens

### Light Theme
- **Surface & Backgrounds:**
  - `background`: `#FAF8F5` (Warm Alabaster / Soft Cream)
  - `surface`: `#FFFFFF` (Pure White cards)
  - `surfaceVariant`: `#F4EFEA` (Input fields, inactive pills)
  - `divider`: `#EDE8E1`

- **Primary & Accents:**
  - `primary`: `#7457DA` (Deep Calming Violet/Lilac)
  - `primaryLight`: `#EDE8FA` (Selected pill background)
  - `primaryDark`: `#5B3FC0`
  - `onPrimary`: `#FFFFFF`

- **Cycle Phase Colors:**
  - `period`: `#F37B82` (Warm Coral / Soft Crimson)
  - `periodLight`: `#FCEBEB`
  - `fertile`: `#70D6C3` (Mint / Aqua)
  - `fertileLight`: `#E5FAF5`
  - `ovulation`: `#F7C268` (Warm Honey Amber)
  - `ovulationLight`: `#FEF7EB`
  - `predicted`: `#D1C9E8` (Dashed lilac border / soft indicator)

- **Typography & Neutrals:**
  - `textPrimary`: `#2D283E` (Deep charcoal purple)
  - `textSecondary`: `#7C788A` (Muted slate lavender)
  - `textTertiary`: `#A8A4B6`

### Dark Theme (Reminders / Night View)
- `background`: `#13121A` (Deep Midnight)
- `surface`: `#1C1B26` (Dark elevated slate card)
- `surfaceVariant`: `#262534`
- `primary`: `#9378FF`
- `textPrimary`: `#F5F3FF`
- `textSecondary`: `#A39EB8`

---

## 3. Typography Hierarchy
- **Font Family:** `Plus Jakarta Sans` or system `San Francisco / Roboto`
- `displayLarge`: 32px, SemiBold (e.g. Day number "Day 14")
- `headlineMedium`: 22px, Bold (Greeting "Good morning ☀️")
- `titleMedium`: 17px, SemiBold (Card titles, Section headers)
- `bodyLarge`: 15px, Regular (Main descriptions, article snippets)
- `bodyMedium`: 13px, Medium (Secondary notes, pill tags, bottom nav labels)
- `labelSmall`: 11px, SemiBold (Caps badges, stats indicators)

---

## 4. Key UI Components & Interactions

### Circular Cycle Tracker (`TodayScreen`)
- Outer segmented ring showing total cycle days (typically 28 days).
- Filled arc showing current day progress with gradient transition between phases (Menstrual -> Follicular -> Ovulation/Fertile -> Luteal).
- Center text showing:
  - Big number: `Day 14`
  - Phase pill: `Fertile window`
  - Subtitle: `High chance of conception`

### Log Day Bottom Sheet (`LogDaySheet`)
- Draggable modal bottom sheet with rounded top corners (radius: 28px).
- Flow pill selector with custom SVG/Vector droplet levels: `None`, `Light`, `Medium`, `Heavy`.
- Mood selector: 5 large tactile emoji buttons (`Happy`, `Calm`, `Irritable`, `Sad`, `Anxious`).
- Symptoms: Wrap layout of selectable chips with active purple fill and inactive grey border.
- Other trackers: List tiles with custom toggle switches.

### Calendar Grid (`CalendarScreen`)
- Month pagination with left/right chevrons.
- Circular date badges with multicolor badges:
  - Red dot: Period day
  - Cyan ring: Fertile window
  - Solid amber dot: Ovulation day
  - Dotted lilac ring: Predicted period
- Cycle view linear bar at bottom: "Day 14 of 28 - 14 days left".

### Insights & Analytics (`InsightsScreen`)
- Tab pills: `3 months`, `6 months`, `1 year`.
- Metric cards: Cycle length (line sparkline), period length, cycle variation.
- Common symptoms: Horizontal animated progress bars with percentage badges.
- Heatmap grid: 28-column matrix mapping cycle days against symptoms.
