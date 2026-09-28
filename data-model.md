# data-model.md - Database Schema & Mathematical Models

## 1. Local Database Technology
- **Database Engine:** SQLite (using Flutter `sqflite` or `drift`)
- **Encryption Option:** SQLCipher or local AES-256 file encryption for export/backup.
- **Constraints:** Zero remote network access, full ACID compliance, cascading deletes on user profile reset.

---

## 2. Table Definitions

### Table: `user_settings`
Stores user profile configuration, baseline cycle assumptions, and security preferences.
```sql
CREATE TABLE user_settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    default_cycle_length INTEGER NOT NULL DEFAULT 28,  -- typical cycle length in days (21-45)
    default_period_length INTEGER NOT NULL DEFAULT 5,   -- typical bleed duration in days (2-10)
    luteal_phase_length INTEGER NOT NULL DEFAULT 14,   -- days from ovulation to next cycle
    app_lock_enabled INTEGER NOT NULL DEFAULT 0,       -- 0 = disabled, 1 = enabled
    pin_hash TEXT,                                     -- salted SHA-256 PIN hash
    biometric_enabled INTEGER NOT NULL DEFAULT 0,
    disguise_mode_enabled INTEGER NOT NULL DEFAULT 0,  -- 0 = normal, 1 = calculator/notes mode
    panic_hide_enabled INTEGER NOT NULL DEFAULT 1,
    notifications_enabled INTEGER NOT NULL DEFAULT 1,
    period_reminder_days_before INTEGER DEFAULT 3,
    daily_log_reminder_time TEXT DEFAULT '21:00',
    theme_mode TEXT NOT NULL DEFAULT 'system',         -- 'light', 'dark', 'system'
    onboarding_completed INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

### Table: `cycles`
Identifies individual menstrual cycles demarcated by the start of a period.
```sql
CREATE TABLE cycles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    start_date TEXT NOT NULL UNIQUE,                   -- ISO-8601 'YYYY-MM-DD'
    end_date TEXT,                                     -- ISO-8601 'YYYY-MM-DD' (day before next start_date)
    cycle_length INTEGER,                              -- calculated days between start_date and next cycle
    period_length INTEGER,                             -- count of consecutive bleed days
    is_predicted INTEGER NOT NULL DEFAULT 0,           -- 1 if statistically projected, 0 if actual
    notes TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

### Table: `daily_logs`
Granular day-by-day logs for symptoms, flow, mood, energy, and notes.
```sql
CREATE TABLE daily_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    log_date TEXT NOT NULL UNIQUE,                     -- ISO-8601 'YYYY-MM-DD'
    flow_intensity TEXT,                               -- 'none', 'light', 'medium', 'heavy'
    mood TEXT,                                         -- 'happy', 'calm', 'irritable', 'sad', 'anxious'
    pain_level INTEGER,                                -- 0 to 5 scale
    energy_level INTEGER,                              -- 0 to 5 scale
    notes TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

### Table: `daily_symptoms`
Normalized mapping for multi-select symptoms.
```sql
CREATE TABLE daily_symptoms (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    daily_log_id INTEGER NOT NULL REFERENCES daily_logs(id) ON DELETE CASCADE,
    symptom_key TEXT NOT NULL,                         -- 'cramps', 'headache', 'bloating', 'acne', 'back_pain', 'fatigue', 'nausea', 'breast_tenderness', 'mood_swings'
    severity INTEGER DEFAULT 1                         -- 1 = mild, 2 = moderate, 3 = severe
);
```

### Table: `tracker_entries`
Dynamic custom trackers (medication, supplements, workouts, water intake).
```sql
CREATE TABLE tracker_entries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    daily_log_id INTEGER NOT NULL REFERENCES daily_logs(id) ON DELETE CASCADE,
    tracker_type TEXT NOT NULL,                        -- 'medication', 'supplement', 'workout', 'custom'
    name TEXT NOT NULL,                                -- e.g. 'Iron supplement', 'Vitamin D', 'Pilates'
    is_completed INTEGER NOT NULL DEFAULT 1,
    value TEXT                                         -- dosage or duration
);
```

---

## 3. On-Device Statistical Prediction Engine

Rather than relying on machine learning or external cloud models, predictions are computed deterministically on-device using empirical medical algorithms:

### 1. Cycle Length Moving Average
- If `tracked_cycles >= 3`: Calculate weighted moving average (recent cycles have higher weight):
  $$\text{CycleLength}_{\text{pred}} = \frac{3 \cdot C_{n} + 2 \cdot C_{n-1} + 1 \cdot C_{n-2}}{6}$$
- If `tracked_cycles < 3`: Fallback to user baseline setting (default: 28 days).

### 2. Period Duration Moving Average
- Unweighted average of last 3 verified bleed durations:
  $$\text{PeriodLength}_{\text{pred}} = \text{round}\left(\frac{1}{k}\sum_{i=1}^k P_i\right)$$

### 3. Ovulation & Fertile Window Calculation
- Standard biological luteal phase is typically 14 days before the next period starts.
- **Estimated Ovulation Day:**
  $$\text{OvulationDate} = \text{NextPeriodStartDate} - 14 \text{ days}$$
- **Fertile Window:** Sperm viability is ~5 days and ovum viability is ~1 day:
  $$\text{FertileStart} = \text{OvulationDate} - 5 \text{ days}$$
  $$\text{FertileEnd} = \text{OvulationDate} + 1 \text{ day}$$ (6-day fertile window)

### 4. Confidence Score Formula
- Standard deviation of cycle lengths ($\sigma$):
  $$\sigma = \sqrt{\frac{1}{N}\sum (C_i - \bar{C})^2}$$
- Confidence percentage:
  $$\text{Confidence} = \max(60\%, \min(95\%, 95\% - 5 \times \sigma))$$
  (Gives 85%-95% for regular cycles, adjusting lower if variance is high).
