# Curriculum Elevation Roadmap

**Last updated:** 2026-04-11
**Purpose:** Track which degree programs and general education courses still need elevation from thin scaffolding (~20KB files) to realistic college workloads (~100-250KB files), matching the quality established by CS, Cybersecurity, Game Design, and Business Administration.

## Elevation Standard

A course is considered "elevated" when its JSON file meets these criteria:

### Regular courses (100-level through 400-level)
- **Size:** 100-250KB per file
- **Sessions:** 15 weekly sessions (matching 15-week semester)
- **Per session:** 4 learning objectives, 3+ real textbook references (authors/editions/chapters), substantive 800-1200 char introduction, 8-10 key concept bullets, specific demonstration, 3-4 setup requirements, 4 review key/value pairs
- **Assessments:** 5 quizzes × 3 analytical questions each with full worked answers and point rubrics, 3 major assignments with deliverables and grading rubrics
- **Grading breakdown:** 5 categories totaling 100%
- **Course policies:** 5 keys (attendance, late submissions, collaboration, academic integrity, technology requirements)

### Capstone/Internship courses (xxx490, xxx491)
- **Size:** 20-40KB per file (intentionally smaller)
- **Format:** Milestone-based, matching CS490/CS491 template
- **Structure:** ~6 sessions, 0 quizzes, 4-5 major assignments, grading breakdown with milestone deliverables/final product/postmortem/peer eval (capstone) or internship performance/weekly journals/final report/presentation (internship)

### Exemplar files to reference when elevating
- `assets/courses/CS301.json` — classic regular course exemplar (150KB)
- `assets/courses/BA301.json` — business domain regular course (225KB)
- `assets/courses/CS490.json` — capstone exemplar (28KB)
- `assets/courses/CS491.json` — internship exemplar (26KB)

---

## Progress Overview

| Status | Count | Degrees |
|---|---|---|
| ✅ **Elevated** | 4 | BSCS001, BSCY001, BAGD001, BSBA001 |
| ❌ **Pending** | 8 | BSHI001, BSPM001, BAPS001, BAEL001, BAED001, BADC001, BAIS001, BAUX001 |
| 🎓 **Gen Ed** | 14 courses pending | All GEN101-GEN404 still thin |

**Total courses still to elevate (not counting cross-listed):** ~170 regular courses + ~16 capstone/internship + 14 gen ed = **~200 courses**

---

## Cross-Listed Course Policy

Cross-listed courses (courses prefixed differently from the owning degree — e.g., BIO101 in BSHI001) are **not elevated as part of the owning degree**. They should be elevated when a degree that specializes in their domain is tackled, or handled separately as shared electives. This policy was established during BSBA001 elevation (skipped ECON201, ECON202, STAT301).

**Cross-listed courses accumulated across remaining degrees:**
- BIO101, BIO102, BIO105 (would belong to a Biology degree if added)
- HIST201, HLTH201, HLTH201
- PHIL201, PSY205, PSY210, SOC201
- CS105, CS110, CS115, CS120, CS125 (small CS service courses — 100KB elevated CS105 already)
- COMM201, JOUR201, LING201, MKTG201
- LANG201, LANG202
- BUS201, BUS202, ECON201, ECON202, FIN201, STAT301, STAT302, MATH205-MATH210
- ART201, CRIM201

**Already elevated as part of other degrees:** CS105 (101KB, in BSHI001 cross-listed), CS120 (97KB, in BAED001 cross-listed — close to threshold).

---

## Per-Degree Roadmap

### ❌ BSHI001 — Bachelor of Science in Health Informatics

**Primary prefix:** HI
**Course count:** 24 total (17 regular + 2 capstone + 5 cross-listed)
**Estimated effort:** ~20 single-subagent passes
**Domain guidance:** Healthcare Information Technology, EHR systems, HIPAA, clinical decision support, biostatistics, healthcare quality

**Regular courses needing elevation (17):**
- HI101 Introduction to Health Informatics
- HI102 Healthcare Systems and Delivery
- HI103 Medical Terminology
- HI201 Electronic Health Records
- HI202 Health Data Management
- HI203 Healthcare Database Systems
- HI301 Health Information Systems
- HI302 Healthcare Analytics
- HI303 Telemedicine and Digital Health
- HI304 Health Information Security
- HI401 Healthcare Quality Management
- HI402 Clinical Decision Support Systems
- HI403 Public Health Informatics
- HI404 Healthcare Compliance and Regulations
- HI405 Health Information Exchange
- HI406 Healthcare Project Management
- HI407 Research Methods in Health Informatics

**Capstone courses needing elevation (2):**
- HI490 Health Informatics Capstone
- HI491 Healthcare Industry Practicum

**Cross-listed (skip):** BIO101, BIO102, CS105 (already elevated), STAT302, HLTH201

**Key textbooks to cite:**
- Hoyt & Yoshihashi, "Health Informatics: Practical Guide" (7th ed.)
- Shortliffe & Cimino, "Biomedical Informatics: Computer Applications in Health Care" (5th ed.)
- Wager, Lee & Glaser, "Health Care Information Systems" (4th ed.)
- Nelson & Staggers, "Health Informatics: An Interprofessional Approach" (3rd ed.)

**Real cases to weave in:** Epic vs Cerner (Oracle) market, VA electronic health record rollout failures, IBM Watson Health failure, HITECH Act and Meaningful Use, Anthem 2015 breach, UnitedHealth 2024 Change Healthcare ransomware, MyChart patient portals, COVID contact tracing apps.

---

### ❌ BSPM001 — Bachelor of Science in Project Management

**Primary prefix:** PM
**Course count:** 25 total (20 regular + 2 capstone + 3 cross-listed)
**Estimated effort:** ~22 single-subagent passes
**Domain guidance:** PMBOK Guide (7th ed.), Agile/Scrum, waterfall, risk management, EVM, leadership

**Note:** BA408 (Project Management Fundamentals in BSBA001) is already elevated at 190KB and can be referenced as a domain exemplar — but the BSPM001 courses go much deeper into specific aspects of PM.

**Regular courses needing elevation (20):**
- PM101 Introduction to Project Management *(can reuse BA408 as starting point)*
- PM102 Project Planning and Scheduling
- PM103 Project Cost Management
- PM201 Project Risk Management
- PM202 Quality Management in Projects
- PM203 Project Communication Management
- PM301 Agile Project Management
- PM302 Team Leadership and Management
- PM303 Stakeholder Management
- PM304 Project Procurement Management
- PM401 Strategic Project Management
- PM402 Program and Portfolio Management
- PM403 International Project Management
- PM404 IT Project Management
- PM405 Construction Project Management
- PM406 Project Management Tools and Software
- PM407 Change Management
- PM408 Contract Management
- PM409 Project Management Ethics
- PM410 Performance Measurement and Control

**Capstone (2):** PM490, PM491

**Cross-listed (skip):** BUS201, BUS202, FIN201

**Key textbooks:**
- PMI, "A Guide to the Project Management Body of Knowledge (PMBOK Guide)" (7th ed.)
- Kerzner, "Project Management: A Systems Approach" (13th ed.)
- Schwalbe, "Information Technology Project Management" (9th ed.)
- Sutherland, "Scrum: The Art of Doing Twice the Work in Half the Time"

**Real cases:** Big Dig Boston, Denver airport baggage, Apollo 11, Sydney Opera House, HealthCare.gov, Boeing 787 development, Heathrow Terminal 5, Crossrail/Elizabeth Line, Berlin Brandenburg Airport (BER), Three Gorges Dam, London 2012 Olympics, Scaled Agile Framework adoption.

---

### ❌ BAPS001 — Bachelor of Arts in Psychology

**Primary prefix:** PSY
**Course count:** 25 total (20 regular + 2 capstone + 3 cross-listed)
**Estimated effort:** ~22 single-subagent passes
**Domain guidance:** APA research standards, major psychology schools, experimental methodology, ethics (IRB), DSM-5-TR

**Regular courses needing elevation (20):**
- PSY101 Introduction to Psychology
- PSY102 Research Methods in Psychology
- PSY103 Statistical Methods in Psychology
- PSY201 Developmental Psychology
- PSY202 Cognitive Psychology
- PSY203 Social Psychology
- PSY301 Abnormal Psychology
- PSY302 Personality Psychology
- PSY303 Biological Psychology
- PSY304 Learning and Memory
- PSY401 Clinical Psychology
- PSY402 Counseling Psychology
- PSY403 Educational Psychology
- PSY404 Industrial/Organizational Psychology
- PSY405 Health Psychology
- PSY406 Cross-Cultural Psychology
- PSY407 Psychological Testing and Assessment
- PSY408 Ethics in Psychology
- PSY409 Psychology of Technology and Digital Behavior
- PSY410 Advanced Research Seminar

**Capstone (2):** PSY490, PSY491

**Cross-listed (skip):** BIO105, SOC201, PHIL201

**Key textbooks:**
- Myers & DeWall, "Psychology" (13th ed.)
- Schacter, Gilbert, Wegner & Nock, "Psychology" (5th ed.)
- Kahneman, "Thinking, Fast and Slow"
- Cialdini, "Influence: The Psychology of Persuasion"
- Gazzaniga, Ivry & Mangun, "Cognitive Neuroscience" (5th ed.)
- APA Publication Manual (7th ed.)

**Real cases:** Milgram obedience (1961), Stanford Prison (1971, later critiqued), Bobo doll (Bandura), Asch conformity, Little Albert (ethical cautionary tale), replication crisis (Bem, Many Labs), Dunning-Kruger effect, Kahneman/Tversky prospect theory, ELIZA chatbot therapy, modern CBT apps, Gottman marriage research, APA ethics code violations.

---

### ❌ BAEL001 — Bachelor of Arts in English Literature

**Primary prefix:** ENG
**Course count:** 25 total (21 regular + 2 capstone ALREADY ELEVATED + 2 cross-listed)
**Estimated effort:** ~21 single-subagent passes
**Special note:** ENG490 and ENG491 appear elevated already at ~23-26KB each (marginal — verify against CS490/491 template quality before declaring complete)

**Regular courses needing elevation (21):**
- ENG101 Introduction to Literary Studies
- ENG102 Creative Writing Fundamentals
- ENG103 Advanced Composition
- ENG201 British Literature I
- ENG202 British Literature II
- ENG203 American Literature I
- ENG301 American Literature II
- ENG302 World Literature
- ENG303 Contemporary Literature
- ENG304 Poetry and Poetics
- ENG401 Shakespeare Studies
- ENG402 Literary Theory and Criticism
- ENG403 Digital Humanities
- ENG404 Women's Literature
- ENG405 Multicultural Literature
- ENG406 Genre Studies
- ENG407 Literature and Media
- ENG408 Professional Writing
- ENG409 Publishing and Editorial Studies
- ENG410 Teaching Literature
- ENG411 Advanced Creative Writing

**Capstone (appears done):** ENG490 Senior Thesis in Literature (23KB), ENG491 Literature Internship (26KB) — **verify quality**

**Cross-listed (skip):** HIST201, LING201

**Key textbooks:**
- Greenblatt et al., "The Norton Anthology of English Literature" (10th ed.)
- Baym et al., "The Norton Anthology of American Literature" (10th ed.)
- Abrams & Harpham, "A Glossary of Literary Terms" (11th ed.)
- Eagleton, "Literary Theory: An Introduction" (3rd ed.)
- Strunk & White, "The Elements of Style" (for writing courses)

**Real authors/works to cite:** Shakespeare (multiple plays), Chaucer, Milton, Austen, Dickens, Wordsworth, Woolf, Hemingway, Faulkner, Morrison, Baldwin, Achebe, García Márquez, Murakami, contemporary works. Literary theorists: Bakhtin, Derrida, Butler, Said, Spivak.

---

### ❌ BAED001 — Bachelor of Arts in Educational Technology

**Primary prefix:** ED
**Course count:** 25 total (21 regular + 2 capstone + 2 cross-listed)
**Estimated effort:** ~23 single-subagent passes
**Domain guidance:** Learning theory, instructional design (ADDIE, Dick & Carey), LMS, accessibility, learning analytics

**Regular courses needing elevation (21):**
- ED101 Foundations of Education
- ED102 Learning Theory and Development
- ED103 Introduction to Educational Technology
- ED201 Instructional Design
- ED202 Digital Learning Environments
- ED203 Educational Assessment and Evaluation
- ED301 Multimedia in Education
- ED302 Online Learning and E-Learning
- ED303 Educational Games and Simulations
- ED304 Mobile Learning Technologies
- ED401 AI in Education
- ED402 Virtual Reality in Education
- ED403 Learning Management Systems
- ED404 Educational Data Analytics
- ED405 Accessibility in Educational Technology
- ED406 Professional Development and Training
- ED407 Educational Technology Leadership
- ED408 Research Methods in Educational Technology
- ED409 Global Perspectives in Educational Technology
- ED410 Emerging Technologies in Education
- ED411 Educational Technology Policy and Ethics

**Capstone (2):** ED490, ED491

**Cross-listed (skip):** PSY205, CS120 (almost elevated at 97KB)

**Key textbooks:**
- Morrison, Ross & Kemp, "Designing Effective Instruction" (8th ed.)
- Mayer, "Multimedia Learning" (3rd ed.)
- Merrill, "First Principles of Instruction"
- Reiser & Dempsey, "Trends and Issues in Instructional Design and Technology" (5th ed.)
- CAST, "Universal Design for Learning Guidelines" (v3.0)

**Real cases:** Khan Academy rise, Coursera/edX MOOC era, Duolingo gamification, ChatGPT in schools (2023-), Zoom School pandemic lessons, 1:1 laptop programs (failures and successes), LAUSD iPad rollout failure 2013, Minerva University, Alt-School failure, Georgia Tech OMSCS scale.

---

### ❌ BADC001 — Bachelor of Arts in Digital Communications

**Primary prefix:** DC
**Course count:** 25 total (21 regular + 2 capstone ALREADY ELEVATED + 2 cross-listed)
**Estimated effort:** ~21 single-subagent passes
**Special note:** DC490 and DC491 appear elevated already (24KB and 27KB — **verify quality**)

**Regular courses needing elevation (21):**
- DC101 Introduction to Digital Communications
- DC102 Digital Media Fundamentals
- DC103 Writing for Digital Platforms
- DC201 Social Media Strategy and Management
- DC202 Content Creation and Storytelling
- DC203 Digital Marketing and Advertising
- DC301 Video Production and Editing
- DC302 Podcast Production and Audio Content
- DC303 Search Engine Optimization (SEO)
- DC304 Data Analytics for Communications
- DC401 Brand Communication and Identity
- DC402 Crisis Communication in Digital Age
- DC403 Influencer Marketing and Partnerships
- DC404 Email Marketing and Automation
- DC405 Mobile Communication Strategies
- DC406 International Digital Communications
- DC407 Ethics in Digital Communications
- DC408 Emerging Technologies in Communications
- DC409 Public Relations in Digital Era
- DC410 Strategic Communication Planning
- DC411 Legal Issues in Digital Media

**Capstone (verify):** DC490, DC491

**Cross-listed (skip):** JOUR201, MKTG201

**Note:** BA304 Digital Marketing and BA407 Business Communication from BSBA001 are already elevated and can serve as domain exemplars. There's substantive topic overlap — coordinate to avoid duplication.

**Key textbooks:**
- Chaffey & Ellis-Chadwick, "Digital Marketing: Strategy, Implementation and Practice" (8th ed.)
- Kotler et al., "Marketing 5.0: Technology for Humanity"
- Guffey & Loewy, "Essentials of Business Communication" (12th ed.)
- Scott, "The New Rules of Marketing and PR" (8th ed.)

**Real cases:** Glossier influencer model, Dollar Shave Club viral launch, BP/Tylenol crisis comms, United Airlines dragging incident, Patagonia Don't Buy This Jacket, TikTok algorithm virality, Taylor Swift "Shake it Off" SEO manipulation.

---

### ❌ BAIS001 — Bachelor of Arts in International Studies

**Primary prefix:** IS
**Course count:** 25 total (21 regular + 2 capstone + 2 cross-listed)
**Estimated effort:** ~23 single-subagent passes
**Domain guidance:** International relations theory, comparative politics, regional studies, global economics, international law

**Regular courses needing elevation (21):**
- IS101 Introduction to International Studies
- IS102 World Geography and Cultures
- IS103 Comparative Government and Politics
- IS201 International Relations Theory
- IS202 Global Economics
- IS203 International Law
- IS301 Diplomacy and Foreign Policy
- IS302 International Organizations
- IS303 Global Security Studies
- IS304 International Development
- IS401 Human Rights and International Justice
- IS402 Global Environmental Issues
- IS403 International Business and Trade
- IS404 Regional Studies: Asia-Pacific
- IS405 Regional Studies: Europe
- IS406 Regional Studies: Middle East and Africa
- IS407 Regional Studies: Latin America
- IS408 International Communication
- IS409 Global Health and Social Issues
- IS410 Digital Diplomacy and Cyber Governance
- IS411 Research Methods in International Studies

**Capstone (2):** IS490, IS491

**Cross-listed (skip):** LANG201, LANG202

**Key textbooks:**
- Mingst, McKibben & Arreguín-Toft, "Essentials of International Relations" (9th ed.)
- Goldstein & Pevehouse, "International Relations" (11th ed.)
- Baylis, Smith & Owens, "The Globalization of World Politics" (8th ed.)
- Friedman, "The World is Flat" (updated ed.)
- Huntington, "The Clash of Civilizations and the Remaking of World Order"
- Rodrik, "The Globalization Paradox"

**Real cases:** Russia-Ukraine war (2022-present), China's Belt and Road Initiative, Brexit, EU response to COVID, Paris Climate Agreement and withdrawal/rejoin, WTO decline and USMCA, Iran nuclear deal (JCPOA), Cuban Missile Crisis as IR theory test case, Rwandan genocide and R2P, Syrian civil war, Venezuela crisis.

---

### ❌ BAUX001 — Bachelor of Arts in User Experience Design

**Primary prefix:** UX
**Course count:** 25 total (21 regular + 2 capstone + 2 cross-listed)
**Estimated effort:** ~23 single-subagent passes
**Domain guidance:** User research methods, design thinking, prototyping tools (Figma, Sketch), accessibility (WCAG), interaction patterns

**Regular courses needing elevation (21):**
- UX101 Introduction to User Experience Design
- UX102 Design Thinking and Process
- UX103 Visual Design Fundamentals
- UX201 User Research Methods
- UX202 Information Architecture
- UX203 Wireframing and Prototyping
- UX301 Interaction Design
- UX302 Usability Testing and Evaluation
- UX303 Mobile User Experience Design
- UX304 Web User Experience Design
- UX401 Advanced Prototyping Techniques
- UX402 Accessibility and Inclusive Design
- UX403 UX for Emerging Technologies
- UX404 Service Design
- UX405 Design Systems and Guidelines
- UX406 UX Strategy and Business Impact
- UX407 Voice User Interface Design
- UX408 Data-Driven Design
- UX409 Cross-Platform Design
- UX410 UX Portfolio Development
- UX411 Professional UX Practice

**Capstone (2):** UX490, UX491

**Cross-listed (skip):** PSY210, CS125 (partially elevated at 62KB)

**Key textbooks:**
- Norman, "The Design of Everyday Things" (revised ed., 2013)
- Krug, "Don't Make Me Think, Revisited" (3rd ed.)
- Cooper, Reimann, Cronin & Noessel, "About Face: The Essentials of Interaction Design" (4th ed.)
- Tidwell, Brewer & Valencia, "Designing Interfaces" (3rd ed.)
- Weinschenk, "100 Things Every Designer Needs to Know About People" (2nd ed.)
- Buxton, "Sketching User Experiences"
- WCAG 2.2 (W3C)

**Real cases:** Apple iPhone launch 2007 (multi-touch revolution), Google Material Design system, Airbnb redesign 2014, Stripe Checkout iterations, Slack onboarding, Figma's collaborative design disruption, dark pattern lawsuits (FTC actions), Notion's flexible blocks, Linear's speed-first design.

---

## 🎓 General Education (Gen Ed) — 14 courses pending

Gen Ed courses are shared across all degree programs and are currently thin. They should be elevated as a coherent batch since they serve many constituencies.

**Communication & Critical Thinking (4 courses, 12 credits):**
- ❌ GEN101 Digital Communication Fundamentals
- ❌ GEN102 Critical Thinking in the Digital Age
- ❌ GEN103 Academic Writing and Research
- ❌ GEN104 Public Speaking and Presentation

**Mathematics & Quantitative Reasoning (3 courses, 9 credits):**
- ❌ GEN201 College Mathematics
- ❌ GEN202 Statistics and Data Analysis
- ❌ GEN203 Logic and Problem Solving

**Science & Technology (3 courses, 9 credits):**
- ❌ GEN301 Introduction to Computer Literacy
- ❌ GEN302 Digital Ethics and AI Society
- ❌ GEN303 Environmental Science and Sustainability

**Social Sciences & Humanities (4 courses, 12 credits):**
- ❌ GEN401 Global Cultures and Diversity
- ❌ GEN402 History of Innovation and Technology
- ❌ GEN403 Psychology of Learning
- ❌ GEN404 Economics in the Digital Era

**Gen Ed elevation guidance:** These are 100/200-level survey courses. They should be slightly less deep than major courses (target 80-120KB each rather than 150-250KB), but still have all 15 sessions, 5 quizzes, 3 assignments, etc. They should be accessible to students across all majors, not assume prior technical background.

---

## Recommended Execution Order

Based on (a) topic diversity, (b) content-reuse opportunities, (c) complementarity with elevated degrees:

### Phase 1: Bridge degrees with BA/CS overlap (leverages existing work)
1. **BSPM001** Project Management — reuses BA408, overlaps with business frameworks
2. **BADC001** Digital Communications — overlaps with BA304, BA407
3. **BAUX001** UX Design — overlaps with CS (HCI), bridges design and tech

### Phase 2: Humanities and social science
4. **BAPS001** Psychology — rich domain, standalone
5. **BAEL001** English Literature — capstones may already be done
6. **BAIS001** International Studies — overlaps with BA302, BA303

### Phase 3: Specialty technical
7. **BSHI001** Health Informatics — specialized domain, benefits from later elevation
8. **BAED001** Educational Technology — meta-interesting; close to what this app is

### Phase 4: Foundation
9. **GEN101-GEN404** Gen Ed (14 courses) — benefits all degrees once complete

---

## Operational Lessons from BSBA001 Run

**What worked:**
- **One-course-at-a-time subagents** (final 6 BA courses) — robust to usage limits, each failure loses at most one course
- **Python patching** for partial-completion files (BA303 missing quizzes/assignments, BA407 missing sessions 11-15) — preserved existing work and added only what was missing
- **Rich domain-specific prompts** with real textbook citations, real company case lists, and topic outlines — produced substantive content on first pass

**What didn't work:**
- **Parallel 5-course subagents** — one failure wastes ~5× the usage budget, and crashes lose partial work
- **Generic prompts without domain guidance** — produced thinner generic content
- **Opus model for bulk content generation** — hit usage limits faster than sonnet

**Recommended approach for future degrees:**
1. Dispatch **one subagent per course** sequentially
2. Use **sonnet model** (`model: "sonnet"`) for content generation subagents to preserve opus budget for orchestration
3. Supply **rich course-specific prompts** including topic outline, textbook list, and case studies
4. After each subagent completes, **verify file size and JSON structure** before moving on
5. If a subagent leaves a partial file, use **Python patching** to add only what's missing rather than re-generating the whole course
6. **Commit after each degree** rather than at the very end, to lock in progress
7. **Cross-listed courses** are intentionally skipped per degree; elevate them only when the degree that specializes in their domain is tackled (or handle separately as a batch of shared electives)

---

## Quick Reference: What's Elevated Today

| Degree | Status | Courses Elevated |
|---|---|---|
| BSCS001 Computer Science | ✅ | 23/23 major |
| BSBA001 Business Administration | ✅ | 22/22 BA-prefixed |
| BSCY001 Cybersecurity | ✅ | 24/24 major |
| BAGD001 Game Design & Media | ✅ | 25/25 major |
| BSHI001 Health Informatics | ❌ | 0/19 |
| BSPM001 Project Management | ❌ | 0/22 |
| BAPS001 Psychology | ❌ | 0/22 |
| BAEL001 English Literature | ❌ | 0/21 (capstones marginal) |
| BAED001 Educational Technology | ❌ | 0/23 |
| BADC001 Digital Communications | ❌ | 0/21 (capstones marginal) |
| BAIS001 International Studies | ❌ | 0/23 |
| BAUX001 UX Design | ❌ | 0/23 |
| Gen Ed (GEN101-GEN404) | ❌ | 0/14 |

**Total remaining to elevate:** ~188 courses across 8 degrees + 14 gen ed.
