# ReviseGram for iOS (SwiftUI)

Native iOS port of **ReviseGram** built with **SwiftUI**, **Swift Concurrency (`async/await`)**, local JSON persistence, and the **Gemini 2.5 Flash REST API** (with full offline fallback).

## Included Features (Parity with ReviseGram Android)

- **7 Cambridge IGCSE Subjects (`SubjectCatalogue`)**:
  - Physics (`0625` · 2026–2028)
  - Mathematics (`0580` · 2025–2027)
  - Chemistry (`0620` · 2026–2028)
  - Business (`0264` · 2027–2029)
  - Economics (`0455` · 2027–2029)
  - Information and Communication Technology (ICT) (`0417` · 2026–2028)
  - English – First Language (`0500` · 2027–2029)
- **Editorial Design System**:
  - Muted Indigo brand accent (`#4F46E5`), Warm Paper light mode (`#FAF9F6`), Deep Charcoal dark mode (`#111215`), and semantic status colours.
- **Core Revision Flows**:
  - **Onboarding & Subject Selection**: Choose active IGCSE subjects.
  - **Home Feed**: Time-of-day editorial greeting, "Pick up where you left off" card, Revision Stories viewer with micro-quizzes, Quick Tools bar, subject filter chips, and interactive formula/quiz/exam-tip cards.
  - **Explore**: Instant keyword and syllabus code search with trending topic chips.
  - **Create**: Publish Revision Notes, 4-Option Quiz Challenges, Flashcards, Past Paper Questions, or Formula Cheat Sheets.
  - **Progress**: Overall accuracy, streak & points summary, claimable Daily Revision Missions, per-subject competency bars, Badges & Milestones, and AI Revision Diagnostics.
  - **Profile**: Saved bookmarks, custom Revision Folders (Collections), Rewards Shop, and Settings (Dark Mode, Subject Selection, and optional Gemini API key).
  - **Full-Screen Study Tools**:
    - **Flashcards**: 3D flip animation with spaced-repetition interval scheduling.
    - **Timed Exam Mode Simulator**: Validated multiple-choice exam questions by subject and tier (`Core` / `Extended`) with live countdown timer and `A*`–`U` grade diagnostics.
    - **Past Papers Tracker**: Log question scores and examiner mistake notes by year (`2020`–`2025`), session (`May/June`, `Oct/Nov`, `Feb/March`), and paper component.
    - **Cambridge AI Tutors & AI Examiner**: Per-subject AI tutor chat, AI Syllabus Content Generator, and AI Answer Marking with offline fallback.

## How to Run in Xcode

1. Unzip `ReviseGram-iOS.zip` on a Mac with **Xcode 15.0 or later**.
2. Open `ReviseGram.xcodeproj` in Xcode.
3. Select an iPhone Simulator (e.g., **iPhone 16 Pro**, iOS 17.0+) or your connected iPhone.
4. *(Optional)* In the app, open **Profile → Settings** (or the gear icon in the top bar) to enter your `GEMINI_API_KEY` for live Gemini 2.5 Flash responses. All study tools also work offline out of the box.
5. Press **Cmd + R** to build and run.
