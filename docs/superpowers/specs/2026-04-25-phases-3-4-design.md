# Gym Helper — Phases 3 & 4 Design Spec
**Date:** 2026-04-25
**Status:** Approved

---

## Scope

Implement the remaining four screens and the Gemini AI report pipeline:

| Phase | Deliverables |
|-------|-------------|
| 3 — Reports | Reports tab (trend chart + session list), Report detail screen, Cloud Function + Gemini integration |
| 4 — Home & Profile | Home screen (streak, quick-start, last session), Profile screen (stats, level picker, settings, sign-out) |

---

## Phase 3 — Reports Tab & AI Pipeline

### 3a. Reports Tab (`ReportsListScreen`)

**Layout:** Single scrollable screen.

**Improvement Trend Chart** (top section)
- Line chart: form score (y-axis, 0–100) over the last N sessions (x-axis, chronological)
- Gradient area fill below the line in lime (`#CFFF50` at 25% opacity → transparent)
- Dots at each data point; the most recent dot is hollow (open circle)
- Three stat chips below the chart:
  - Score improvement (first session → latest, shown as `+N`)
  - Good-rep percentage average across all sessions
  - Total session count
- Chart card uses `bgElevated` background, `borderDefault` border, 16 px radius
- Chart implemented with `fl_chart` package (`LineChart` widget)

**Session Cards** (scrollable list below chart)
Each card shows:
- Exercise icon + name, date + duration
- Aggregate form score (right-aligned, colored: lime ≥ 80, cyan 60–79, amber < 60)
- Per-rep bar chart: one bar per rep (capped at 20 bars; if > 20 reps, show first 20 with a "+N more" label), colored by score (lime ≥ 80, cyan 60–79, amber < 60, red < 40), height proportional to score
- "AI Report ready" badge (animated lime dot + text) when `reportStatus == 'ready'`; "Generating…" spinner when `pending`; "Retry" when `failed`
- Tap navigates to Report Detail screen

**Empty state:** When the user has no sessions, show a centered icon + "No sessions yet — start your first workout" + a lime quick-start button.

**Data source:** `FirestoreService.watchSessions(uid)` real-time stream, wrapped in a `SessionsProvider` (ChangeNotifier).

---

### 3b. Report Detail Screen (`ReportDetailScreen`)

**Route:** `/report/:sessionId` — receives `sessionId` as path parameter.

**Layout (top to bottom, scrollable):**

1. **Score hero** — exercise icon, name, date + duration, large form score number, rating tag (`GREAT` / `GOOD` / `NEEDS WORK`), three stat chips (total reps, good reps, good-rep %)
2. **AI Report sections** (visible once `reportStatus == 'ready'`):
   - ✨ **What You're Doing Well** — lime bullet list of strengths from `ReportModel.strengths`
   - 🎯 **What to Improve** — cyan bullet list from `ReportModel.improvements`
   - 🚀 **Next Session Goal** — dark box containing `ReportModel.nextSessionGoal`
   - Summary text (`ReportModel.summary`) shown as a subtitle above the strength/improvement sections
3. **Per-rep bar chart** — same bar design as the session card but full-width with rep number labels on the x-axis and a color legend (Great / Good / Needs work)

**Loading state:** While `reportStatus == 'pending'`, show an animated "Generating your AI report…" shimmer placeholder where the AI sections will appear.

**Error state:** If `reportStatus == 'failed'`, show "Report unavailable" with a Retry button that calls an HTTPS callable Cloud Function (`retryReport`) passing `{sessionId}`. This function runs the Gemini generation directly (since `onCreate` won't re-fire on an existing document).

**Data source:** `FirestoreService.watchReport(sessionId)` real-time stream.

---

### 3c. Cloud Function — Gemini Report Generation

**Trigger:** Firestore `onCreate` on `sessions/{sessionId}`.

**Function flow:**
1. Read the new session document
2. Fetch the user document to get `fitnessLevel`
3. Call Gemini API (`gemini-2.0-flash`) with a structured prompt
4. Parse the JSON response
5. Write a new document to `reports/{sessionId}` (using sessionId as the report doc ID for easy lookup)
6. Update `sessions/{sessionId}.reportStatus` to `'ready'` (or `'failed'` on error)

**Gemini prompt structure:**
```
You are a personal fitness coach. Analyze this workout and respond with JSON only.

Exercise: {exerciseType}
User level: {fitnessLevel}
Total reps: {totalReps}
Form score: {formScore}/100
Good reps: {goodReps}/{totalReps}
Common errors: {commonErrors joined by ", "}

Respond with this exact JSON structure:
{
  "summary": "2-3 sentence overall assessment",
  "strengths": ["strength 1", "strength 2"],
  "improvements": ["improvement 1", "improvement 2"],
  "nextSessionGoal": "one specific actionable goal for next session",
  "overallScore": <number 0-100>
}

Adapt tone to level: beginner = encouraging, intermediate = technique-focused, advanced = performance-optimizing.
```

**Error handling:**
- Gemini API failure → set `reportStatus = 'failed'`, log error
- JSON parse failure → retry once with a stricter prompt; on second failure → set `reportStatus = 'failed'`
- Function is idempotent: if `reportStatus` is already `'ready'`, skip execution

**Environment config:**
- `GEMINI_API_KEY` stored as Firebase Function secret (`firebase functions:secrets:set GEMINI_API_KEY`)
- Runtime: Node.js 20
- Region: `us-central1`

**Firestore report document path:** `reports/{sessionId}` (sessionId doubles as reportId for O(1) lookup — no query needed).

**`FirestoreService`:** `watchReport(sessionId)` already exists and queries by `sessionId` field. Since the report doc ID equals the sessionId, update it to use a direct doc reference `reports/{sessionId}` (no query needed — O(1) read).

---

## Phase 4 — Home Screen & Profile Screen

### 4a. Home Screen (`HomeScreen`)

**Layout (top to bottom):**

1. **Greeting header** — "Good morning/afternoon/evening, {firstName}" (time-aware)
2. **Streak hero card** (`bgElevated`, 18 px radius):
   - 🔥 emoji + large lime day count + "Day streak — keep it going!"
   - 7-dot weekly tracker (Mon–Sun): filled lime for completed days, bright lime with glow for today, `borderDefault` gray for future days
   - If streak is 0: shows "Start your streak today!" with no dots
3. **Quick-start button** (full-width lime `#CFFF50` card):
   - Shows last-used exercise icon + name + rep target
   - Tapping navigates directly to `PositionGuideScreen` with the last exercise pre-configured
   - If no previous session: label reads "Start First Workout" and opens `ExerciseSelectScreen`
4. **Last session card** (`bgElevated`):
   - Exercise icon, name, date/duration, aggregate form score (lime/cyan/amber)
   - Mini per-rep bar chart (first 10 reps shown; "+N more" label if > 10)
   - Stat chips: reps, good reps, score
   - Tap navigates to `ReportDetailScreen` for that session
   - Hidden entirely if no sessions exist

**Data source:** `UserProvider` (for streak, level) + `FirestoreService.watchSessions(uid).first` for last session.

---

### 4b. Profile Screen (`ProfileScreen`)

**Layout (top to bottom):**

1. **Header row** — "PROFILE" title (left) + gear icon settings button (right, opens a modal bottom sheet)
2. **Avatar** — centered, 80 × 80 px, rounded square, lime initial letter on dark background with lime border
3. **Name + email** — centered below avatar
4. **3-stat row card** — Sessions · Total Reps · Day Streak (lime values, gray labels)
5. **Fitness level picker** — three pill buttons side-by-side:
   - 🌱 Beginner / ⚡ Intermediate / 🔥 Advanced
   - Active pill: lime background, dark text
   - Tapping calls `FirestoreService.updateUserLevel(uid, level)` immediately
6. **Sign Out button** — full-width, dark background, red border and text, at the bottom

**Settings bottom sheet** (shown on gear icon tap):
- "Notifications" row (toggle — stubbed for v1, always off)
- "About" row (shows app version)
- Dismiss handle at top

**Data source:** `UserProvider` watches `users/{uid}` real-time for streak, stats, and level.

---

## New Provider: `SessionsProvider`

Wraps `FirestoreService.watchSessions(uid)` and exposes:
- `List<SessionModel> sessions` — full list, ordered by date desc
- `SessionModel? lastSession` — `sessions.firstOrNull`
- `List<double> formScoreTrend` — `sessions.reversed.map((s) => s.formScore).toList()` (oldest first, for the chart)
- `double scoreImprovement` — last score minus first score (clamped to 0 if only one session)
- `double avgGoodRepRate` — average of `goodReps / totalReps` across sessions

Registered in `main.dart` alongside existing providers.

---

## New Package Dependencies

| Package | Purpose |
|---------|---------|
| `fl_chart` | Line chart (trend) and bar chart (per-rep) |
| `firebase_functions` | Cloud Functions HTTP callable (retry endpoint) |

Add to `pubspec.yaml`. Cloud Function dependencies (`@google/generative-ai`, `firebase-admin`, `firebase-functions`) go in `functions/package.json`.

---

## Routing Updates

| Route | Screen | Notes |
|-------|--------|-------|
| `/report/:sessionId` | `ReportDetailScreen` | New — added to `app_router.dart` |
| `/settings` | (bottom sheet, not a route) | Triggered from Profile gear icon |

The Reports list and session card both navigate to `/report/:sessionId`.

---

## Firestore Security Rules Update

Add read access for the `reports` collection:
```
match /reports/{reportId} {
  allow read: if request.auth != null && resource.data.userId == request.auth.uid;
  allow write: if false; // Cloud Function writes only
}
```

---

## Error Handling

| Scenario | Behaviour |
|----------|-----------|
| No sessions yet | Reports tab shows empty state; Home hides last-session card |
| Report pending > 60s | Show "Taking longer than usual…" message with spinner |
| Report failed | Show "Report unavailable" + Retry button (calls HTTP Cloud Function) |
| Firestore offline | Flutter SDK serves cached data; no special handling needed |
| Level update fails | Revert pill selection, show snackbar "Failed to save — try again" |

---

## Testing

- `SessionsProvider` unit tests: verify `formScoreTrend`, `scoreImprovement`, `avgGoodRepRate` calculations with mock data
- Cloud Function integration test: call with a mock session document, verify report written to Firestore
- Manual QA: run 3 sessions on device, verify trend chart updates, report generates within 10s, streak increments correctly
