# Ciara OS — System & Screen Reference

**Version:** 1.0.0 (local-only v1)  
**Stack:** Flutter · Riverpod · GoRouter · Drift (SQLite) · SharedPreferences  
**Design source:** Stitch mockups (`stitch_ciara_os_execution_system/`)

Ciara OS is a personal productivity and execution system. All data is stored locally on device. There is no backend, auth, or cloud sync in v1.

---

## Table of contents

1. [Architecture](#architecture)
2. [Navigation & routing](#navigation--routing)
3. [Data model](#data-model)
4. [Time & metrics](#time--metrics)
5. [Shared UI](#shared-ui)
6. [Primary screens](#primary-screens)
7. [Secondary screens](#secondary-screens)
8. [Enums & domains](#enums--domains)
9. [Stubs & future work](#stubs--future-work)

---

## Architecture

```
lib/
├── main.dart                 # App entry, onboarding bootstrap
├── router/app_router.dart    # GoRouter routes + onboarding redirect
├── database/                 # Drift schema (schema v6)
├── models/                   # Domain types + enums
├── repositories/             # CRUD + queries
├── providers/                # Riverpod wiring
├── services/                 # OnboardingNotifier, DailyActivityStats
├── screens/
│   ├── primary/              # Bottom-nav destinations
│   └── secondary/            # Detail, create/edit, onboarding
├── widgets/                  # Reusable UI by feature area
└── theme/                    # Colors, typography, spacing, ThemeData
```

| Layer | Responsibility |
|-------|----------------|
| **Screens** | Route-level layout, orchestration |
| **Widgets** | Feature UI components |
| **Providers** | Reactive state, streams from DB |
| **Repositories** | Data access |
| **Database** | SQLite via Drift, migrations |

**State management:** `flutter_riverpod` — `StreamProvider` for live lists, `FutureProvider` for single records, `NotifierProvider` for the Deep Work Engine (`focusSessionProvider`) and navigation tab.

**Persistence:**
- **Drift** — tasks, projects, opportunities, weekly reviews
- **SharedPreferences** — onboarding completion, daily focus seconds, streak counters

---

## Navigation & routing

### Onboarding gate

Until `onboarding_complete` is set in SharedPreferences, all routes redirect to `/onboarding`. After completion, `/onboarding` redirects to `/`.

### Primary shell (`ShellRoute`)

Five bottom-nav tabs inside `PrimaryShellScaffold` + `PrimaryNavBar`.

On first shell mount, if an interrupted `focus_sessions` row exists (`endedAt IS NULL`), `PrimaryShellScaffold` shows **Session Recovery** — Resume (restart ticker) or Discard (delete session row).

| Tab | Route | Screen |
|-----|-------|--------|
| Today | `/` | `TodayScreen` |
| Backlog | `/tasks` | `TasksScreen` |
| Projects | `/projects` | `ProjectsScreen` |
| Pipeline | `/opportunities` | `OpportunitiesScreen` |
| Review | `/review` | `ReviewScreen` |

### Secondary routes (full-screen, no bottom nav)

| Route | Screen |
|-------|--------|
| `/onboarding` | `OnboardingScreen` |
| `/tasks/new` | `TaskCreateEditScreen` (create) |
| `/tasks/:id` | `TaskDetailScreen` |
| `/tasks/:id/edit` | `TaskCreateEditScreen` (edit) |
| `/projects/new` | `ProjectCreateEditScreen` (create) |
| `/projects/:id` | `ProjectDetailScreen` |
| `/projects/:id/edit` | `ProjectCreateEditScreen` (edit) |
| `/opportunities/new` | `OpportunityCreateEditScreen` (create) |
| `/opportunities/:id` | `OpportunityDetailScreen` |
| `/opportunities/:id/edit` | `OpportunityCreateEditScreen` (edit) |

**Query parameters:**
- `/tasks/new?projectId=…&title=…` — pre-fill project link and title

---

## Data model

**Schema version:** 6

### Tasks

| Field | Type | Notes |
|-------|------|-------|
| `id` | int | Auto-increment PK |
| `title` | text | Required |
| `domain` | text | `Domain` enum name |
| `status` | text | Default `notStarted` |
| `priority` | text | Default `medium` |
| `started` | bool | Synced with active focus session |
| `today` | bool | In today's execution queue |
| `deadline` | DateTime? | Optional due date |
| `projectId` | int? | FK → projects |
| `notes` | text? | Execution notes |
| `postponeCount` | int | Deferral counter |
| `estimatedDurationMinutes` | int? | Planning estimate for deep work (default UI: 45m) |
| `totalFocusedSeconds` | int | Sum of completed session durations |
| `focusSessionCount` | int | Completed session count |
| `planningAccuracy` | real? | 0–100 score set on task completion |
| `lastFocusSessionAt` | DateTime? | Timestamp of last completed session |
| `createdAt` / `updatedAt` | DateTime | Audit timestamps |

### Focus sessions (`focus_sessions`)

Each row is one deep work session bound to exactly one task. Only one row may have `endedAt IS NULL` at a time (the recoverable active session).

| Field | Type | Notes |
|-------|------|-------|
| `id` | int | PK |
| `taskId` | int | FK → tasks |
| `startedAt` | DateTime | Session start |
| `endedAt` | DateTime? | Null while active |
| `durationSeconds` | int | Final duration (set on complete) |
| `focusQuality` | text? | `deepFocus` · `good` · `okay` · `distracted` |
| `goalReached` | bool | True if duration ≥ 45 minutes |
| `pausedElapsedSeconds` | int | Checkpointed elapsed time |
| `segmentStartedAt` | DateTime? | Non-null when clock is running |
| `createdAt` / `updatedAt` | DateTime | |

### Projects

| Field | Type | Notes |
|-------|------|-------|
| `id` | int | PK |
| `name` | text | Required |
| `domain` | text | `Domain` enum |
| `status` | text | Default `active` |
| `nextAction` | text? | Immediate next step |
| `externalLink` | text? | `http(s)://` URL |
| `description` | text? | Long-form context |
| `timeAllocationDays` | int | Default 30; milestone horizon |
| `createdAt` / `updatedAt` | DateTime | |

### Opportunities

| Field | Type | Notes |
|-------|------|-------|
| `id` | int | PK |
| `title` | text | Required |
| `organization` | text | Required |
| `location` | text | Required (schema v3) |
| `type` | text | `OpportunityType` |
| `status` | text | Pipeline stage |
| `deadline` | DateTime? | Application due date |
| `fitNotes` | text? | Strategic fit notes |
| `documents` | text? | JSON list of doc checklist items |
| `documentsTotal` / `documentsReady` | int | Checklist progress |
| `link` | text? | Application URL or email |
| `leadQuality` | int? | 1–3 rating |
| `createdAt` / `updatedAt` | DateTime | |

### Weekly reviews

| Field | Type | Notes |
|-------|------|-------|
| `id` | int | PK |
| `weekOf` | DateTime | Monday of review week |
| `whatWorked` | text? | What went well |
| `whatFailed` | text? | What slowed you down (legacy column name) |
| `improvementForNextWeek` | text? | One improvement for next week |
| `nextActions` | text? | JSON list of next-week priorities |
| `startedRate` / `focusScore` | real? | Legacy snapshot fields |
| `executionScore` | real? | Encapsulated score at finalize |
| `weeklyNarrative` | text? | Generated executive paragraph |
| `insightsJson` | text? | Snapshot of deterministic insights |
| `totalTasks` / `startedTasks` | int | Week stats snapshot |
| `locked` | bool | Finalized debrief |
| `createdAt` / `updatedAt` | DateTime | |

### Migrations

| Version | Change |
|---------|--------|
| v2 | `opportunities.leadQuality` |
| v3 | `opportunities.location` |
| v4 | `projects.timeAllocationDays` (existing rows → 30) |
| v5 | `focus_sessions` table; task deep work columns |
| v6 | `weekly_reviews`: `improvementForNextWeek`, `executionScore`, `weeklyNarrative`, `insightsJson` |

---

## Time & metrics

Ciara OS tracks **execution quality**, not just elapsed time. Every focus session belongs to exactly one task — there is no standalone timer.

| Concept | Unit | Persisted? | Where used |
|---------|------|------------|------------|
| **Focus session** | Seconds | Yes (`focus_sessions`) | Deep Work card, task detail, AI-ready history |
| **45-min Deep Work Goal** | Seconds | Reference only | Progress ring/bar; timer continues past goal |
| **`started` flag** | Boolean | Yes | Task rows; synced by Deep Work Engine |
| **`today` flag** | Boolean | Yes | Today queue membership |
| **Estimated duration** | Minutes | Yes (task) | Session planning, planning accuracy |
| **Planning accuracy** | 0–100 | Yes (task, on complete) | Task detail, Performance Snapshot |
| **Focus quality** | Enum | Yes (per session) | End-session dialog, daily averages |
| **Task deadline** | Calendar date | Yes | Task detail, backlog badges, filters |
| **Project time allocation** | Days | Yes | Project create/edit, detail, milestone math |
| **Focus uptime (daily)** | Seconds | Yes (SharedPreferences) | Performance Snapshot |
| **Daily streak** | Days | Yes (SharedPreferences) | Performance Snapshot |
| **Weekly started-rate** | % | Computed | Review aggregate efficiency |

### Deep Work Engine

**Provider:** `focusSessionProvider` (`DeepWorkEngineNotifier` + `ActiveDeepWorkState`)

**Repository:** `FocusSessionRepository` — CRUD on `focus_sessions`, start/pause/resume/complete/discard, daily session queries.

**Rules:**
- One globally active session at a time (`endedAt IS NULL`)
- Starting a session for a task creates a `focus_sessions` row and sets `task.started = true`
- Pause checkpoints elapsed time, flushes unflushed seconds to daily stats, sets `task.started = false`
- End session (required focus quality) completes the row, updates task aggregates (`totalFocusedSeconds`, `focusSessionCount`, `lastFocusSessionAt`), clears active state
- Progress toward the 45-minute goal is visual only — the clock keeps running after the goal
- Every 15s while running, elapsed time is checkpointed to SQLite for crash recovery
- On app launch, active session is hydrated but the ticker does not start until the user chooses **Resume** in the recovery dialog

**End session flow:** `showEndSessionDialog` — required rating: Deep Focus · Good · Okay · Distracted.

**Planning accuracy** (`computePlanningAccuracy` in `deep_work_utils.dart`): on task completion, compares `estimatedDurationMinutes` vs `totalFocusedSeconds`. Score 100 = perfect estimate. Stored on the task as `planningAccuracy`.

**Session numbering:** `plannedSessionCount` = ceil(estimate ÷ 45); current session = `focusSessionCount + 1` while active.

**Performance Snapshot (Today)** — `todayPerformanceProvider`:
- *Completed today* — `done` ÷ total in today queue
- *Deep work today* — persisted daily seconds + unflushed active session time
- *Sessions* — completed sessions today (+ active if any)
- *Avg quality* — mean of today's completed session quality scores
- *Planning accuracy* — mean of today-queue tasks with a score
- *Daily streak* — consecutive days with focus activity or completion

**Project remaining days:** `timeAllocationDays − days since createdAt` (calendar days).

---

## Shared UI

### `TodayHeader`

Used on all primary screens and as the app chrome pattern.

- Height: 56px (`AppSpacing.appBarHeight`)
- Left: terminal icon + **Ciara OS** (JetBrains Mono)
- Right: notifications icon (non-functional) + **CM** avatar (hardcoded)

### `EmptyState`

Variants: `compact`, `tasks`, `pipeline`, `projects` — used across list screens when no data or errors.

### Design tokens

- **Typography:** Inter (body/headings) + JetBrains Mono (labels/code)
- **Theme:** Dark mode default; light theme available
- **Domains:** color via `context.domainColor(Domain)` theme extension
- **Max content width:** 1200px (`AppSpacing.containerMax`)

---

## Primary screens

### 1. Today — `/`

**Purpose:** Daily execution view — the screen users open every day.

**Layout (Stitch-aligned):**
```
TodayHeader
└─ ScrollView (max-width 1200, padding 40px)
   ├─ TodayScreenLabel      ("EXECUTION VIEW" / Today / date)
   ├─ TodayActionRow        Filter + New Task
   └─ [wide ≥1024px] 8/4 grid | [narrow] stacked
      ├─ TodayTaskListSection   (main, 8 cols)
      └─ TodaySidebar           (4 cols)
```

**TodayScreenLabel**
- Overline: `EXECUTION VIEW` (primary color)
- Title: **Today** (`displayLarge`)
- Subtitle: full formatted date

**TodayActionRow**
- **Filter** — opens `showTodayFilterSheet` (domain, deadline, status); uses today-specific filter providers
- **New Task** — navigates to `/tasks/new`

**TodayTaskListSection**
- Data: `filteredTodayTasksProvider` (today queue + filters)
- Grouped by domain: Engineering → Security → Opportunities → Builder → Other
- Each group: domain dot + uppercase label + `TodayTaskRow` per task
- **Started toggle** — delegates to `focusSessionProvider` (start / pause / resume)
- Row subtitle shows `Est: … · Act: …` focused time when estimate or actual exists
- Tap row → `/tasks/:id`
- Empty states:
  - No today tasks → "Your day is clear." + Review Backlog
  - Filters match nothing → Clear filters

**TodaySidebar**
1. **DeepWorkCard** — active deep work UI (Stitch `today_ciara_os_final_updated_dark`): task title, session N of M, circular progress toward 45-min goal, focused time, streak, goal-achieved animation; pause/end controls. Idle state prompts task selection.
2. **PerformanceSnapshotCard** — 2×3 grid: completed today, deep work today, sessions, avg quality, planning accuracy, daily streak
3. **BuilderModeCard** — lists builder-domain tasks in today queue, or empty guidance

---

### 2. Backlog (Tasks) — `/tasks`

**Purpose:** Full task inventory with filtering and quick capture.

**Layout:**
```
TodayHeader
└─ Column
   ├─ ListView
   │  ├─ TasksScreenLabel
   │  ├─ TasksFilterBar      (DOMAIN / DEADLINE / STATUS chips)
   │  └─ TasksBacklogListSection
   └─ TasksQuickAddBar       (pinned bottom — tap → /tasks/new)
```

**TasksFilterBar**
- Opens bottom sheets: domain, deadline (today/week/month), status
- Uses shared `domainFilterProvider`, `deadlineFilterProvider`, `statusFilterProvider`

**TasksBacklogListSection**
- Data: `filteredTasksProvider` (all tasks + filters)
- `TaskListTile` with checkbox, domain bar, deadline badge, started toggle
- Long-press → quick actions sheet (status change, today toggle, delete)
- Empty/filtered states via `EmptyState`

---

### 3. Projects — `/projects`

**Purpose:** Domain project registry and entry point to project detail.

**Layout:**
```
TodayHeader
└─ ListView
   ├─ ProjectsScreenLabel
   ├─ "+ NEW PROJECT" button → /projects/new
   ├─ ProjectCard list (or empty state)
   └─ "INITIATE NEW DOMAIN" CTA
```

**ProjectCard**
- Name, domain color, status dot, next action preview
- Tap → `/projects/:id`

**Empty state:** hero visual + "INITIALIZE PROJECT" CTA

---

### 4. Pipeline (Opportunities) — `/opportunities`

**Purpose:** Job/program application pipeline by stage.

**Layout:**
```
TodayHeader
└─ ListView
   ├─ Screen label (active count + stage count)
   └─ Grouped opportunity cards by status
FloatingActionButton → /opportunities/new
```

**Pipeline stages (in order):**
Researching → Applying → Submitted → Interviewing → Offer → Rejected → Closed

- Active stages always expanded
- Rejected / Closed collapsible
- **OpportunityCard** — type tag, org, location, deadline urgency, doc progress
- Long-press → quick actions (advance stage, edit, delete)

**Empty state:** "Pipeline Clear" + LOG FIRST LEAD

---

### 5. Review — `/review`

**Purpose:** Executive Debrief — closes the Ciara OS execution loop. Sequence: Observe → Measure → Understand → Reflect → Improve → Prepare.

**Layout (Stitch Executive Debrief):**
```
TodayHeader
└─ ListView (max-width 1200)
   ├─ ReviewScreenHeader ("Executive Debrief")
   ├─ ExecutionSummaryCard (score + 6 metrics)
   ├─ ExecutionTimeline (Mon–Sun quality bars)
   ├─ WeeklyNarrativeCard (auto-generated paragraph)
   └─ [wide ≥1024px] 8/4 grid | [narrow] stacked
      ├─ ReflectionCard × 3 (what went well, what slowed, improvement)
      └─ ExecutionInsightsPanel + Next Week Priorities checklist
```

**Execution Score** (`ExecutionScoreCalculator`): weighted blend of task completion (25%), deep work consistency (25%), planning accuracy (20%), focus quality (20%), streak consistency (10%). Formula is encapsulated for future evolution.

**Execution Timeline** (`ExecutionTimelineGenerator`): rule-based daily quality — Strong / Moderate / Weak / Review — from completed tasks, focus seconds, and session count per day. UI consumes `ExecutionTimelineDay` models; logic is swappable for AI.

**Execution Insights** (`InsightGenerator`): 3–5 deterministic insights (title, description, recommendation). Examples: high planning accuracy, context switching, morning productivity, longest session, improved execution.

**Weekly Narrative** (`WeeklyNarrativeGenerator`): template paragraph from week metrics and top insight. Stored on finalize.

**Next Week Priorities**: renamed from Immediate Actions; prepopulated from incomplete today/high-priority tasks and active project next actions (`WeeklyReviewService.suggestPriorities`).

**Reflection fields (3):**
- What went well
- What slowed you down
- One improvement for next week

**Finalize Review** — persists `WeeklyReview` with execution score, narrative, insights snapshot, and reflections. Requires at least one reflection field.

**Provider:** `weeklyDebriefProvider` → `WeeklyReviewService.buildDebrief()`

**Future AI extension points:** `ExecutionScoreCalculator`, `ExecutionTimelineGenerator`, `InsightGenerator`, `WeeklyNarrativeGenerator` — each is a standalone service the AI layer can replace or augment without UI changes.

---

## Secondary screens

### Onboarding — `/onboarding`

**Purpose:** First-launch intro; 4-step `PageView`.

| Step | Content | Actions |
|------|---------|---------|
| 0 | Welcome | Skip Intro → Today · Next Step |
| 1 | Domains protocol | Acknowledge Protocol |
| 2 | Started habit demo | Initialize System |
| 3 | System ready | Create first task → `/tasks/new` · Enter Dashboard → `/` |

Completing any exit path calls `OnboardingNotifier.markComplete()`.

---

### Task detail — `/tasks/:id`

**Purpose:** Modal-style execution card for a single task (Stitch task detail).

**Structure:**
```
Dot grid background
└─ Centered card (max 672px)
   ├─ Domain color top bar
   ├─ Header: domain chip + project ref chip | edit + close
   ├─ Title
   ├─ Body grid (wide: 2 columns)
   │  ├─ Current status (pulsing dot if in progress)
   │  ├─ DEEP WORK (`DeepWorkSection` — estimate, total focused, sessions, last session, planning accuracy; tap start/pause/end)
   │  ├─ Deadline (if set)
   │  └─ Parent project link (if linked)
   ├─ Execution notes (inline edit)
   ├─ Metadata: priority, created, last modified, postponed count
   ├─ Add/remove from Today
   └─ Footer: Pause Task + Mark Complete
```

**Interactions:**
- Deep Work Engine shared with Today via `focusSessionProvider`
- End session requires focus quality rating (`showEndSessionDialog`)
- Mark complete → end session if active, set `done`, compute `planningAccuracy`, record active day for streak
- Delete with confirmation dialog

---

### Task create / edit — `/tasks/new`, `/tasks/:id/edit`

**Fields:**
- Title (required)
- Domain (chip selector)
- Priority (LOW → CRITICAL)
- Status (edit only)
- Estimated duration in minutes (optional; powers session planning)
- Deadline (optional date picker)
- Project (dropdown — active/paused/shipped; archived only if already linked)
- Today flag
- Notes

On edit, deep work aggregates (`totalFocusedSeconds`, `focusSessionCount`, `planningAccuracy`, `lastFocusSessionAt`) are preserved.

Edit mode populates from `taskByIdProvider` synchronously when cached.

---

### Project detail — `/projects/:id`

**Purpose:** Project command center.

**Sections:**
- Identity: domain, name, status, description excerpt
- **OPEN PROJECT ↗** (external link) or disabled state
- Next action card (inline edit)
- Linked tasks list (tap → task detail; + Add Task)
- Description card (if present)
- Metadata: created, last modified, time allocation, time remaining, domain
- Danger zone: Archive · Delete

---

### Project create / edit — `/projects/new`, `/projects/:id/edit`

**Fields:**
- Name (required)
- Domain
- Status
- Time allocation in days (required, > 0)
- Next action
- External link (`http://` or `https://`)
- Description

---

### Opportunity detail — `/opportunities/:id`

**Purpose:** Pipeline item deep dive.

**Sections:**
- Header with back + edit
- Type tag + deadline urgency display
- Title, organization, location
- Pipeline stepper (tap stages / advance)
- Application link (URL or `mailto:`)
- Lead quality rating (1–3)
- Documents checklist (toggle completion)
- Fit notes (inline edit)
- Metadata section
- Move to next stage · Delete

---

### Opportunity create / edit — `/opportunities/new`, `/opportunities/:id/edit`

**Fields:**
- Title, organization, location (required)
- Type (JOB, INTERNSHIP, FELLOWSHIP, PROGRAM, MASTERS)
- Status / pipeline stage
- Deadline
- Application link (http/https, mailto, or plain email)
- Lead quality
- Document checklist (add/remove items)
- Fit notes

---

## Enums & domains

### Domain

| Value | Label | Typical use |
|-------|-------|-------------|
| `engineering` | ENGINEERING | Technical work |
| `security` | SECURITY | Security ops |
| `opportunities` | OPPORTUNITIES | Career/pipeline tasks |
| `builder` | BUILDER | Creative/build work |
| `other` | OTHER | Miscellaneous |

Each domain has a distinct accent color in `AppColors` / `CiaraDomainColors`.

### Task status

`notStarted` · `inProgress` · `done` · `stuck`

### Priority

`low` · `medium` · `high` · `critical`

### Project status

`active` · `paused` · `shipped` · `archived`

### Opportunity status (pipeline)

`researching` · `applying` · `submitted` · `interviewing` · `offer` · `rejected` · `closed`

### Opportunity type

`job` · `internship` · `fellowship` · `program` · `masters`

---

## Stubs & future work

| Feature | Current state |
|---------|---------------|
| Export Report (Review) | Snackbar stub |
| Notifications bell | Non-functional |
| Profile avatar "CM" | Hardcoded |
| Productivity Index | Removed; replaced by Performance Snapshot |
| AI Intelligence Layer | Future; deep work session history designed for estimation, quality, and abandonment queries |
| Cloud sync / auth | Not in v1 |
| Profile / Settings screens | Not implemented |

---

## Running & migrations

```bash
flutter pub get
flutter run
```

After a schema migration bump, do a **full restart** (not just hot reload) so Drift migrations apply.

**Platforms tested:** Linux desktop, Chrome web.

---

## File index (screens)

| File | Route(s) |
|------|----------|
| `screens/primary/today_screen.dart` | `/` |
| `screens/primary/tasks_screen.dart` | `/tasks` |
| `screens/primary/projects_screen.dart` | `/projects` |
| `screens/primary/opportunities_screen.dart` | `/opportunities` |
| `screens/primary/review_screen.dart` | `/review` |
| `screens/secondary/onboarding_screen.dart` | `/onboarding` |
| `screens/secondary/task_detail_screen.dart` | `/tasks/:id` |
| `screens/secondary/task_create_edit_screen.dart` | `/tasks/new`, `/tasks/:id/edit` |
| `screens/secondary/project_detail_screen.dart` | `/projects/:id` |
| `screens/secondary/project_create_edit_screen.dart` | `/projects/new`, `/projects/:id/edit` |
| `screens/secondary/opportunity_detail_screen.dart` | `/opportunities/:id` |
| `screens/secondary/opportunity_create_edit_screen.dart` | `/opportunities/new`, `/opportunities/:id/edit` |

### Deep Work widgets (`lib/widgets/deep_work/`)

| File | Role |
|------|------|
| `deep_work_card.dart` | Today sidebar active-session card |
| `deep_work_section.dart` | Task detail deep work block |
| `end_session_dialog.dart` | Required quality rating on session end |
| `session_recovery_dialog.dart` | Resume / discard after unexpected close |

### Deep Work data layer

| File | Role |
|------|------|
| `database/tables/focus_sessions_table.dart` | Drift table definition |
| `models/focus_session_record.dart` | Session domain model |
| `models/enums/focus_quality.dart` | Quality enum + numeric scores |
| `repositories/focus_session_repository.dart` | Session persistence |
| `providers/focus_session_provider.dart` | Deep Work Engine notifier |
| `providers/focus_session_repository_provider.dart` | Repository DI |
| `utils/deep_work_utils.dart` | Goal constants, planning accuracy, formatting |

### Executive Debrief services (`lib/services/`)

| File | Role |
|------|------|
| `weekly_review_service.dart` | Orchestrates debrief data, priority suggestions |
| `execution_score_calculator.dart` | Weighted Execution Score formula |
| `execution_timeline_generator.dart` | Rule-based daily execution quality |
| `insight_generator.dart` | Deterministic weekly insights |
| `weekly_narrative_generator.dart` | Template executive paragraph |

### Review widgets (`lib/widgets/review/`)

| File | Role |
|------|------|
| `execution_summary_card.dart` | Executive Summary metrics grid |
| `execution_timeline.dart` | Weekly quality timeline |
| `execution_insights_panel.dart` | Insight tiles |
| `weekly_narrative_card.dart` | Auto-generated narrative |
| `reflection_card.dart` | Stitch-style reflection inputs |
| `next_actions_checklist.dart` | Next Week Priorities |

---

*Last updated to match codebase state including Executive Debrief (schema v6), Deep Work Engine, and expanded Performance Snapshot.*
