# Phase 2: BAGD001 Curriculum Content Generation — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Generate complete course content (descriptions, syllabi, quizzes, assignments) for all 24 remaining courses in the Game Design and Media degree, plus update the course descriptions file.

**Architecture:** Each course gets a JSON file at `assets/courses/{COURSE_ID}.json` following the GD401.json template structure. Course descriptions are added to `assets/data/courses.json`. Content is generated following the prerequisite chain (100-level → 200-level → 300-level → 400-level).

**Tech Stack:** JSON data files, Flutter asset system

**Spec:** `docs/superpowers/specs/2026-04-03-university-fixes-and-curriculum-design.md` (Phase 2 section)

**Depends on:** Phase 1 completion (specifically Task 9 — dynamic class loading)

---

## Content Template Reference

Every course JSON file follows this structure (from GD401.json):

```json
{
  "course_info": {
    "course_id": "XX###",
    "title": "...",
    "credit_hours": N,
    "duration": "15 weeks",
    "meeting_schedule": "...",
    "prerequisites": ["..."]
  },
  "class_schedule": [
    {
      "week_number": N,
      "session_number": N,
      "date": "YYYY-MM-DD",
      "topic": "...",
      "duration": "50 minutes",
      "learning_objectives": ["..."],
      "readings": ["..."],
      "lecture_notes": {
        "introduction": "...",
        "key_concepts": ["..."],
        "demonstration": "...",
        "setup_requirements": ["..."],
        "review": [{"key": "...", "value": "..."}]
      }
    }
  ],
  "assessments": {
    "quizzes": [
      {
        "quiz": N,
        "week": N,
        "topic": "...",
        "duration": "30 minutes",
        "questions": [
          {
            "question": "...",
            "type": "short_answer|essay|calculation|code",
            "points": N,
            "answer": "expected answer text",
            "rubric": [{"key": "criterion", "value": points}]
          }
        ],
        "total_points": N
      }
    ],
    "major_assignments": [
      {
        "assignment": N,
        "title": "...",
        "week_assigned": N,
        "week_due": N,
        "points": N,
        "description": "...",
        "objectives": ["..."],
        "deliverables": ["..."]
      }
    ]
  },
  "grading_breakdown": {
    "quizzes": {"percentage": 25, "description": "..."},
    "assignments": {"percentage": 35, "description": "..."},
    "participation": {"percentage": 15, "description": "..."},
    "final_project": {"percentage": 25, "description": "..."}
  },
  "course_policies": {
    "attendance": "...",
    "late_submissions": "...",
    "collaboration": "...",
    "academic_integrity": "...",
    "technology_requirements": "..."
  }
}
```

## Content Quality Rules

- Each course: 15 weeks, 2 sessions per week = 30 sessions
- Dates: Spring 2024 semester starting Jan 15, MWF schedule. Mon sessions get odd session numbers, Wed sessions get even.
- 4-5 quizzes per course, spaced every 3 weeks (weeks 3, 6, 9, 12, 15)
- 2-3 questions per quiz, mix of types appropriate to the course
- 2-3 major assignments, increasing in complexity
- Quiz questions MUST have real expected answers and meaningful rubrics
- Prerequisites must form a coherent chain within the degree
- Lecture notes must include domain-specific concepts, not generic filler
- Each quiz: 20-30 total points. Each assignment: 100-200 points.

## Academic Calendar

```
Week 1:  Jan 15, Jan 17
Week 2:  Jan 22, Jan 24
Week 3:  Jan 29, Jan 31
Week 4:  Feb 5,  Feb 7
Week 5:  Feb 12, Feb 14
Week 6:  Feb 19, Feb 21
Week 7:  Feb 26, Feb 28
Week 8:  Mar 4,  Mar 6
Week 9:  Mar 11, Mar 13
Week 10: Mar 18, Mar 20    (Spring Break - Mar 25-29)
Week 11: Apr 1,  Apr 3
Week 12: Apr 8,  Apr 10
Week 13: Apr 15, Apr 17
Week 14: Apr 22, Apr 24
Week 15: Apr 29, May 1
```

---

### Task 1: Year 1 Foundation Courses (6 courses)

**Files:**
- Create: `assets/courses/GD101.json`
- Create: `assets/courses/GD102.json`
- Create: `assets/courses/GD103.json`
- Create: `assets/courses/CS115.json`
- Create: `assets/courses/ART201.json`
- Create: `assets/courses/COMM201.json`

- [ ] **Step 1: Generate GD101 — Introduction to Game Design (3 credits)**

Prerequisites: None.
Topics: History of games, game design principles, player psychology, game genres, paper prototyping, playtesting fundamentals, game design documents, iterative design, player experience, industry overview.
Quizzes: 4 (weeks 3, 6, 9, 12). Assignments: 2 (board game prototype weeks 4-7, digital game design document weeks 10-14).

Write to `assets/courses/GD101.json`.

- [ ] **Step 2: Generate GD102 — Game Theory and Mechanics (3 credits)**

Prerequisites: GD101.
Topics: Core mechanics, feedback loops, game balance, reward systems, probability in games, economic systems, emergent gameplay, progression systems, difficulty curves, competitive vs cooperative design.
Quizzes: 4. Assignments: 2 (mechanics analysis paper, original game system design).

Write to `assets/courses/GD102.json`.

- [ ] **Step 3: Generate GD103 — Digital Art Fundamentals (3 credits)**

Prerequisites: None.
Topics: Color theory, composition, digital drawing tools, pixel art, vector graphics, typography, UI design basics, concept art, asset pipelines, art direction.
Quizzes: 4. Assignments: 3 (digital illustration portfolio, UI mockup, character concept sheet).

Write to `assets/courses/GD103.json`.

- [ ] **Step 4: Generate CS115 — Programming for Games (3 credits)**

Prerequisites: None.
Topics: Variables and data types, control flow, functions, OOP basics, game loops, collision detection basics, event handling, arrays/lists, simple physics, debugging.
Quizzes: 5. Assignments: 3 (text adventure, simple arcade game, physics simulation).

Write to `assets/courses/CS115.json`.

- [ ] **Step 5: Generate ART201 — Digital Design Principles (3 credits)**

Prerequisites: GD103.
Topics: Layout and grid systems, visual hierarchy, branding, motion design principles, responsive design, accessibility, design systems, prototyping tools, user research basics, design critique.
Quizzes: 4. Assignments: 2 (brand identity package, interactive prototype).

Write to `assets/courses/ART201.json`.

- [ ] **Step 6: Generate COMM201 — Media Studies (3 credits)**

Prerequisites: None.
Topics: Media theory, digital media landscape, audience analysis, content creation, storytelling across media, social media strategy, media ethics, intellectual property, transmedia narratives, media criticism.
Quizzes: 4. Assignments: 2 (media analysis essay, multimedia content project).

Write to `assets/courses/COMM201.json`.

- [ ] **Step 7: Verify all 6 files parse correctly**

```bash
cd university_ui
for f in assets/courses/GD101.json assets/courses/GD102.json assets/courses/GD103.json assets/courses/CS115.json assets/courses/ART201.json assets/courses/COMM201.json; do
  python3 -c "import json; json.load(open('$f')); print('OK: $f')" || echo "FAIL: $f"
done
```

---

### Task 2: Year 2 Courses (3 courses)

**Files:**
- Create: `assets/courses/GD201.json`
- Create: `assets/courses/GD202.json`
- Create: `assets/courses/GD203.json`

- [ ] **Step 1: Generate GD201 — 2D Game Development (4 credits)**

Prerequisites: CS115, GD101.
Topics: 2D game engines (Godot/Unity 2D), sprite animation, tile maps, 2D physics, camera systems, parallax scrolling, particle systems, save/load systems, 2D lighting, polish and juice.
Quizzes: 5. Assignments: 3 (platformer prototype, top-down RPG demo, polished 2D game).

Write to `assets/courses/GD201.json`.

- [ ] **Step 2: Generate GD202 — 3D Modeling and Animation (4 credits)**

Prerequisites: GD103, ART201.
Topics: 3D modeling fundamentals (Blender), polygon modeling, UV unwrapping, texturing, rigging, skeletal animation, walk cycles, facial animation, low-poly optimization, export pipelines.
Quizzes: 4. Assignments: 3 (hard-surface model, character model with rig, animated short).

Write to `assets/courses/GD202.json`.

- [ ] **Step 3: Generate GD203 — Interactive Storytelling (3 credits)**

Prerequisites: GD101, COMM201.
Topics: Narrative design, branching narratives, dialogue systems, world-building, environmental storytelling, character arcs, player agency, quest design, cutscene design, narrative tools (Ink, Twine, Yarn Spinner).
Quizzes: 4. Assignments: 2 (interactive fiction prototype, narrative design document for a game).

Write to `assets/courses/GD203.json`.

- [ ] **Step 4: Verify all 3 files parse correctly**

```bash
cd university_ui
for f in assets/courses/GD201.json assets/courses/GD202.json assets/courses/GD203.json; do
  python3 -c "import json; json.load(open('$f')); print('OK: $f')" || echo "FAIL: $f"
done
```

---

### Task 3: Year 3 Courses (4 courses)

**Files:**
- Create: `assets/courses/GD301.json`
- Create: `assets/courses/GD302.json`
- Create: `assets/courses/GD303.json`
- Create: `assets/courses/GD304.json`

- [ ] **Step 1: Generate GD301 — Game Programming (4 credits)**

Prerequisites: CS115, GD201.
Topics: Game architecture patterns, component-entity systems, state machines, AI pathfinding (A*), spatial partitioning, memory management, multithreading basics, networking fundamentals, shader programming intro, optimization techniques.
Quizzes: 5. Assignments: 3 (AI system implementation, networked multiplayer prototype, optimized game engine component).

Write to `assets/courses/GD301.json`.

- [ ] **Step 2: Generate GD302 — Level Design (3 credits)**

Prerequisites: GD201, GD102.
Topics: Level design principles, player flow, pacing, environmental puzzles, combat spaces, open world vs linear, procedural generation, grayboxing, playtesting levels, accessibility in level design.
Quizzes: 4. Assignments: 2 (single-player level with graybox, multiplayer map with playtesting report).

Write to `assets/courses/GD302.json`.

- [ ] **Step 3: Generate GD303 — Character Design and Development (3 credits)**

Prerequisites: GD202, GD203.
Topics: Character archetypes, visual character design, character sheets, personality and motivation, character animation principles, facial expressions, character customization systems, NPC design, companion AI design, character presentation in UI.
Quizzes: 4. Assignments: 2 (character design bible, animated character showcase).

Write to `assets/courses/GD303.json`.

- [ ] **Step 4: Generate GD304 — Game Audio and Sound Design (3 credits)**

Prerequisites: GD201.
Topics: Audio fundamentals, sound effect creation (Foley, synthesis), adaptive music systems, spatial audio, audio middleware (FMOD/Wwise), voice acting direction, audio implementation in engines, mixing and mastering, procedural audio, audio accessibility.
Quizzes: 4. Assignments: 2 (sound design reel for a game scene, adaptive audio system implementation).

Write to `assets/courses/GD304.json`.

- [ ] **Step 5: Verify all 4 files parse correctly**

```bash
cd university_ui
for f in assets/courses/GD301.json assets/courses/GD302.json assets/courses/GD303.json assets/courses/GD304.json; do
  python3 -c "import json; json.load(open('$f')); print('OK: $f')" || echo "FAIL: $f"
done
```

---

### Task 4: Year 4 Core Courses (10 courses)

**Files:**
- Create: `assets/courses/GD402.json`
- Create: `assets/courses/GD403.json`
- Create: `assets/courses/GD404.json`
- Create: `assets/courses/GD405.json`
- Create: `assets/courses/GD406.json`
- Create: `assets/courses/GD407.json`
- Create: `assets/courses/GD408.json`
- Create: `assets/courses/GD409.json`
- Create: `assets/courses/GD410.json`
- Create: `assets/courses/GD490.json`

- [ ] **Step 1: Generate GD402 — Mobile Game Development (3 credits)**

Prerequisites: GD301, GD201.
Topics: Mobile platforms (iOS/Android), touch input design, mobile UI patterns, performance on mobile, monetization models, push notifications, analytics integration, app store optimization, mobile-specific shaders, cross-platform development.
Quizzes: 4. Assignments: 2 (mobile game prototype, store-ready game package).

- [ ] **Step 2: Generate GD403 — Virtual Reality and Augmented Reality (4 credits)**

Prerequisites: GD401, GD301.
Topics: VR/AR hardware, spatial interaction design, locomotion systems, hand tracking, 3D UI in VR, AR marker tracking, mixed reality, motion sickness mitigation, spatial audio for VR, performance optimization for XR.
Quizzes: 4. Assignments: 3 (VR room-scale experience, AR mobile app, mixed reality prototype).

- [ ] **Step 3: Generate GD404 — Game Testing and Quality Assurance (3 credits)**

Prerequisites: GD301.
Topics: QA methodology, test plan creation, bug reporting, regression testing, automated testing, performance profiling, compatibility testing, playtesting methodology, localization testing, certification requirements.
Quizzes: 4. Assignments: 2 (comprehensive test plan for a game, automated test suite).

- [ ] **Step 4: Generate GD405 — Game Marketing and Publishing (3 credits)**

Prerequisites: GD102, COMM201.
Topics: Game marketing strategy, community building, press kits, trailer creation, social media marketing, influencer relations, platform requirements, launch planning, post-launch support, indie vs publisher paths.
Quizzes: 4. Assignments: 2 (marketing plan and press kit, game launch campaign simulation).

- [ ] **Step 5: Generate GD406 — Multiplayer Game Design (3 credits)**

Prerequisites: GD301, GD302.
Topics: Network architectures (client-server, P2P), latency compensation, matchmaking, anti-cheat, social systems, cooperative design, competitive balance, server infrastructure, live operations, community management tools.
Quizzes: 4. Assignments: 2 (multiplayer game prototype, server architecture design document).

- [ ] **Step 6: Generate GD407 — Indie Game Development (3 credits)**

Prerequisites: GD301, GD405.
Topics: Solo/small team workflows, scope management, rapid prototyping, art style on a budget, audio on a budget, marketing with no budget, crowdfunding, early access strategy, community feedback loops, post-mortem analysis.
Quizzes: 4. Assignments: 2 (game jam prototype in 48 hours, indie business plan).

- [ ] **Step 7: Generate GD408 — Game Analytics and Monetization (3 credits)**

Prerequisites: GD102, GD405.
Topics: Player analytics, funnel analysis, A/B testing, retention metrics, free-to-play design, ethical monetization, loot box regulations, subscription models, ad integration, data-driven design decisions.
Quizzes: 4. Assignments: 2 (analytics dashboard design, monetization strategy proposal).

- [ ] **Step 8: Generate GD409 — Serious Games and Gamification (3 credits)**

Prerequisites: GD102, GD203.
Topics: Serious game design, educational games, health games, training simulations, gamification frameworks, behavioral psychology, engagement metrics, accessibility, social impact games, case studies.
Quizzes: 4. Assignments: 2 (educational game prototype, gamification design for a non-game context).

- [ ] **Step 9: Generate GD410 — Game Industry Professional Practices (3 credits)**

Prerequisites: Senior standing (GD401 or equivalent).
Topics: Portfolio development, resume and interview prep, studio culture, project management (Agile/Scrum), intellectual property law, contracts, workplace ethics, crunch and sustainability, career paths, networking.
Quizzes: 4. Assignments: 2 (professional portfolio, mock studio pitch).

- [ ] **Step 10: Generate GD490 — Game Design Capstone Project (4 credits)**

Prerequisites: GD401, GD301, GD302.
Topics: This is a project-based course. Students form teams and develop a complete game from concept to playable demo over 15 weeks. Weekly sessions are structured as milestone reviews and working sessions.
Quizzes: 0 (project-based). Assignments: 5 (concept document, prototype milestone, alpha build, beta build, final gold build with postmortem).

Grading breakdown for GD490 is different:
```json
"grading_breakdown": {
  "milestone_deliverables": {"percentage": 40, "description": "Five milestone submissions"},
  "final_game": {"percentage": 30, "description": "Quality of the final playable build"},
  "postmortem": {"percentage": 15, "description": "Written analysis of development process"},
  "peer_evaluation": {"percentage": 15, "description": "Team contribution assessment"}
}
```

- [ ] **Step 11: Verify all 10 files parse correctly**

```bash
cd university_ui
for f in assets/courses/GD402.json assets/courses/GD403.json assets/courses/GD404.json assets/courses/GD405.json assets/courses/GD406.json assets/courses/GD407.json assets/courses/GD408.json assets/courses/GD409.json assets/courses/GD410.json assets/courses/GD490.json; do
  python3 -c "import json; json.load(open('$f')); print('OK: $f')" || echo "FAIL: $f"
done
```

---

### Task 5: Internship Course

**Files:**
- Create: `assets/courses/GD491.json`

- [ ] **Step 1: Generate GD491 — Game Industry Internship (3 credits)**

Prerequisites: Senior standing, GD410.
Topics: This is an internship/practicum course. Sessions are structured as weekly check-ins and professional development workshops. Students complete an internship (real or simulated) and document their experience.
Quizzes: 0. Assignments: 4 (internship plan, mid-term reflection, supervisor evaluation form, final internship report with portfolio additions).

Grading breakdown:
```json
"grading_breakdown": {
  "internship_performance": {"percentage": 40, "description": "Supervisor evaluation of work quality"},
  "weekly_journals": {"percentage": 20, "description": "Weekly reflection journals"},
  "final_report": {"percentage": 25, "description": "Comprehensive internship report"},
  "presentation": {"percentage": 15, "description": "Final presentation to faculty"}
}
```

- [ ] **Step 2: Verify file parses correctly**

```bash
python3 -c "import json; json.load(open('university_ui/assets/courses/GD491.json')); print('OK')"
```

---

### Task 6: Update Course Descriptions File

**Files:**
- Modify: `assets/data/courses.json`

- [ ] **Step 1: Add Game Design and Media course descriptions**

Update `assets/data/courses.json` to include a `"Game Design and Media"` key with full descriptions for all 25 BAGD001 courses plus the 3 supporting courses (ART201, CS115, COMM201). Each entry needs: `course_id`, `title`, `credit_hours`, `description`, `learning_objectives`, `covered_materials`.

The descriptions should be extracted/summarized from the class detail files generated in Tasks 1-5.

- [ ] **Step 2: Verify the updated courses.json parses correctly**

```bash
python3 -c "
import json
with open('university_ui/assets/data/courses.json') as f:
    data = json.load(f)
gd = data['courses'].get('Game Design and Media', [])
print(f'Game Design and Media: {len(gd)} courses with descriptions')
for c in gd:
    assert 'course_id' in c
    assert 'title' in c
    assert 'credit_hours' in c
    assert 'description' in c
    assert 'learning_objectives' in c
    assert 'covered_materials' in c
    print(f'  {c[\"course_id\"]}: {c[\"title\"]} - OK')
print('All course descriptions valid')
"
```

---

### Task 7: Final Verification

- [ ] **Step 1: Count all class detail files**

```bash
ls -1 university_ui/assets/courses/*.json | grep -v schema | wc -l
```

Expected: 25 files (24 new + GD401 original).

- [ ] **Step 2: Run flutter pub get and flutter analyze**

```bash
cd university_ui && flutter pub get && flutter analyze
```

Expected: No errors.

- [ ] **Step 3: Run flutter test**

```bash
cd university_ui && flutter test
```

Expected: All tests pass.

- [ ] **Step 4: Verify dynamic class loading discovers all courses**

If the app can be run, navigate through:
1. Home → Degrees → BAGD001 (Game Design and Media)
2. Verify each course card shows "AI Class Available" badge
3. Tap into a course → verify "Start Learning" button appears
4. Tap into a class → verify Schedule, Quizzes, and Assignments tabs populate
