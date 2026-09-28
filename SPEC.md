# SPEC.md - Monthly: Privacy-First Period Tracker

## 1. Product Vision
**Monthly** is an offline-first, privacy-focused menstrual health and cycle tracking application. It is engineered with zero running costs (no cloud databases, no external LLM/AI APIs, no subscriptions required for core functionality) and guaranteed data sovereignty ("Your data stays on your phone").

## 2. Core Principles
- **100% Offline-First:** All user data is stored locally in SQLite (`drift` or `sqflite`). Zero telemetry or analytics tracking by default.
- **Zero Running Costs:** No hosted backend or paid API keys required to operate.
- **Cave/Disguise Mode:** Privacy protection allowing the app to masquerade under a harmless disguise (e.g., calculator or notes icon/screen) with quick panic hide.
- **Doctor-Ready Reports:** Instant client-side PDF export of cycle history, symptoms, and health trends without server involvement.
- **Statistical Math over AI:** Cycle predictions, fertile windows, and ovulation estimates calculated deterministically on-device via statistical rolling averages.

---

## 3. Screen & Feature Specifications

### 1. Onboarding (`Screen 1`)
- **Key Message:** "Your data stays on your phone" — Track your cycle, understand your body and take control privately and securely.
- **Highlights:**
  - No account needed
  - All data stored on device
  - You're in control
- **Call to Action:** "Get started" button leading directly to initial cycle setup (last period start date, typical cycle length, typical period duration).

### 2. Today / Home (`Screen 2`)
- **Greeting & Date:** Greeting with dynamic day/night icon, date banner.
- **Cycle Dial / Status Arc:**
  - Visual circular gauge indicating current cycle day (e.g. "Day 14 - Fertile window - High chance of conception").
  - Next period prediction countdown & confidence percentage (e.g., "6 Oct - 10 Oct 2026, 85% confidence").
  - Primary CTA: "+ Log today".
- **Quick Log Shortcuts:**
  - 4 quick cards: Mood, Pain, Flow, Energy.
- **Today's Tip Card:** Educational daily health insight based on current cycle phase.
- **Bottom Navigation Bar (5 tabs):**
  1. Today (Home)
  2. Calendar
  3. Insights
  4. Learn
  5. Me (Settings)

### 3. Calendar View (`Screen 3`)
- **Month Grid:** Interactive calendar with indicators for:
  - Period days (solid red/pink)
  - Fertile window (soft teal/cyan)
  - Ovulation day (solid teal highlight)
  - Predicted period (dashed/bordered indicators)
  - Other logged days
- **Cycle View Progress Bar:** "Day X of Y" with days remaining in current cycle.
- **Log CTA:** Quick action button to log or edit the selected date.

### 4. Log Day Bottom Sheet (`Screen 4`)
- **Flow Selector:** None, Light, Medium, Heavy (custom droplet pill buttons).
- **Mood Selector:** Happy, Calm, Irritable, Sad, Anxious (emoji + label selection).
- **Symptoms Multi-select:** Cramps, Headache, Bloating, Acne, Back pain, Fatigue, Nausea, Breast tenderness, Mood swings.
- **Other Trackers (Toggles/Inputs):**
  - Medication (toggle + dosage note)
  - Supplements
  - Workout / Activity
- **Notes Field:** Free-form optional text input.
- **Save Button:** Commits entry to local SQLite database with instantaneous UI feedback.

### 5. Insights & Analytics (`Screen 5`)
- **Time Range Filters:** 3 months, 6 months, 1 year.
- **Cycle Metrics:**
  - Average cycle length (with interactive trend line chart across months).
  - Average period length.
  - Cycle variation indicator (e.g., ±3 days).
- **Common Symptoms:** Frequency bar chart (Bloating, Cramps, Mood swings, Headache, Acne).
- **Symptoms by Cycle Day:** Matrix heat-map showing correlation between cycle days (1-28+) and reported symptoms.

### 6. Learn / Education (`Screen 6`)
- **Search Bar:** Local offline search across pre-bundled medical/educational guides.
- **Filter Pills:** All, Cycle basics, PCOS, Nutrition, Fitness, Teen guide.
- **Article Cards:**
  - Illustrated thumb, title, reading time (e.g., "Understanding your menstrual cycle - 5 min read").
  - Content bundled statically with app (offline markdown/HTML rendering).

### 7. Me / Settings (`Screen 7`)
- **Profile Header:** Avatar, display name / title.
- **Settings Menu:**
  - My cycle settings (average length, period duration, notification preferences)
  - Custom trackers (add/edit custom symptoms or habits)
  - Doctor report (export health summary)
  - Backup & restore (encrypted local export/import or private Google Drive backup)
  - Privacy & security (App lock, disguise mode, panic hide)
  - Reminders (daily logs, upcoming period, medications)
  - Appearance (Light / Dark mode / Themes)
  - About (license, local-only guarantee, version)

### 8. Doctor Report Export (`Screen 8`)
- **Report Overview:**
  - Date range selector (e.g., 1 Jun 2026 - 23 Sep 2026)
  - Cycle metrics summary (Cycles tracked, average cycle length, average period length)
  - Cycle history table with length consistency
  - Common symptoms breakdown and medication/supplement adherence
- **Action Buttons:**
  - "Share" (Android share sheet with generated PDF)
  - "Export PDF" (save to user's device storage)

### 9. Privacy & Security (`Screen 9`)
- **App Lock:** Toggle PIN or Biometric unlock requirement on app open.
- **Disguise Mode:** Toggle replacing app icon and entry screen with a functional calculator/notepad.
- **Panic Hide:** Rapid swipe or gesture to instantly minimize/switch app.
- **Encrypted Backup:** Export password-protected encrypted database file (`.monthlybackup`).
- **Data Sovereignty Indicator:** "All data stored on device - Your data never leaves your phone."

### 10. Reminders (`Screen 10`)
- **Notification Engine:** Powered by local system notifications (`flutter_local_notifications`).
- **Configurable Alerts:**
  - Period due reminder (e.g., 3 days before)
  - Period start reminder (Day 1)
  - Fertile window alerts
  - Medication & supplement reminders (custom daily time)
  - Daily log reminder (e.g., 9:00 PM)
  - Hydration / lifestyle reminders
- **Dark Mode Support:** Full high-contrast, eye-friendly dark theme.

---

## 4. Phased Implementation Roadmap
- **Phase 1: Foundation & Design System**
  - Flutter workspace setup, theme engine, custom icons, typography, color tokens matching the reference UI.
- **Phase 2: Local Database & Cycle Math Engine**
  - SQLite schema, cycle prediction algorithm (rolling standard deviation and average length), symptom logging models.
- **Phase 3: Core UI Flow**
  - Onboarding, Today Home with circular progress, Log Day bottom sheet, and Calendar view.
- **Phase 4: Insights & Offline Learn Module**
  - Graphs (charts), symptom heatmaps, bundled markdown health guides.
- **Phase 5: Privacy, Security & Disguise Mode**
  - Biometric authentication, PIN lock screen, calculator disguise facade, encrypted JSON/SQLite exports.
- **Phase 6: Notifications & Doctor Report PDF**
  - Local background notifications, PDF generation engine (`pdf` package) and share integrations.
