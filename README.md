# AI-Enabled IDE for Programming Education
### Designing and Evaluating an AI-Enabled IDE for Programming Assignments in Foundational Computer Science Courses
**Baaba Onomaa Amosah — Ashesi University, 2026**

> 📦 **Main Repository:** [baaba-midnight/CAPSTONE_BOA](https://github.com/baaba-midnight/CAPSTONE_BOA) — submodules for the Student IDE, Instructor Dashboard, and Backend are included.

---

## Abstract

The widespread adoption of generative AI tools among students has fundamentally challenged how programming assignments are assessed in foundational computer science courses, as submitted code alone is no longer a reliable indicator of student understanding. Process-oriented assessment — which focuses on *how* students arrived at a solution rather than *what* they produce — offers a promising alternative.

This project addresses that gap by designing, developing, and empirically evaluating an AI-enabled Integrated Development Environment (IDE) for foundational programming assignments. An instructor-defined assistance policy constrains what the AI assistant is and is not permitted to help with, and every student-AI exchange is logged in real time to produce a detailed record of the student's problem-solving process.

**Keywords:** process-oriented assessment, AI-assisted programming education, computer science education, generative AI, interaction logging, instructional control, large language models, foundational programming, student-AI interaction

---

## Problem Statement

Traditional grading in programming courses evaluates only the final submission — an approach built on the assumption that a correct solution reflects genuine understanding. In the context of widespread access to generative AI tools, this assumption is increasingly difficult to sustain. A student may present a working solution without having meaningfully engaged with the underlying concepts at any point during the process.

Most existing AI coding assistants (VS Code, Cursor, Eclipse) prioritise productivity over learning and lack structures for adaptive scaffolding, AI interaction logging, or learning analytics. This project addresses the need for a dedicated AI-powered IDE that provides contextualised, adaptive feedback designed specifically for educational settings.

---

## Research Questions

| Sub-Research Question | Objective |
|---|---|
| **SBQ1** — How can an AI-enabled IDE be designed to structure, constrain, and log student-AI interactions for programming assignments? | Design and implement an AI-enabled IDE that allows instructors to define AI assistance policies and capture detailed interaction logs |
| **SBQ2** — How can student-AI interaction data be used to provide faculty with meaningful evidence of student learning? | Develop a framework for analysing interaction logs that enables instructors to assess student understanding beyond final code submissions |
| **SBQ3** — How does interaction with the AI-enabled IDE encourage student understanding of programming concepts? | Evaluate how constrained assistance, scaffolded feedback, and interaction logging promote deeper conceptual understanding and independent problem-solving |

---

## System Architecture

The system adopts a three-tier architecture separating presentation, application, and data concerns across three primary components:

- **Student IDE (VS Code OSS / Electron)** — A modified version of VS Code packaged as a cross-platform desktop application. Includes student authentication, assignment access, and the StudentChat AI assistant governed by the instructor-defined assistance policy. All interactions are logged in real time.
- **Instructor Dashboard (Web App)** — The faculty-facing control centre. Enables per-assignment AI policy configuration, AI interaction log viewing (with flagging and summary agents), and a process-based grading panel.
- **FastAPI Backend + Supabase** — Mediates all communication between client applications and cloud infrastructure. Handles authentication, assignment management, LLM orchestration via the Groq API (Llama 3.3 70B Versatile), and interaction data persistence in a PostgreSQL database.

### Key Database Tables

| Table | Description |
|---|---|
| `users` | All system users (students and instructors) with roles and auth references |
| `courses` | Courses created by instructors |
| `assignments` | Programming assignments with instructor-defined AI assistance policy |
| `ai_interactions` | Core logging table — every student prompt and AI response during an assignment session |
| `submissions` | Student submission records |
| `student_assignments` | Tracks assignment status per student (not started / in progress / submitted) |

---

## Student IDE Features
> 🔗 [baaba-midnight/student-ide](https://github.com/baaba-midnight/student-ide/tree/d875d4501fa54f555ae598df15e165aaf45071e9)

### 1. Disabled Copy-Paste
To encourage active engagement with the material, copy-paste functionality is disabled in both the editor and the chat interface. Students must manually type all code and queries, which promotes careful reading, deliberate thinking, and genuine interaction with the assignment rather than passive transfer of external code.

### 2. Student Chatbot
The StudentChat assistant is the core pedagogical component of the IDE. Rather than functioning as a general-purpose AI tool, it operates strictly within the boundaries of an instructor-defined assistance policy that encodes the faculty member's pedagogical intent for each assignment. The assistant guides students through their work using scaffolded hints, guiding questions, and conceptual explanations — without writing code on their behalf. Every exchange between the student and the assistant is logged in real time, making the chatbot the primary mechanism for both supporting student learning and generating the process-level evidence that enables process-oriented assessment and grading.

---

## Instructor Dashboard Features
> 🔗 [baaba-midnight/instructor-dashboard](https://github.com/baaba-midnight/instructor-dashboard/tree/ad756cce6d1610672e3867c49f7d8f356e396235)

### 1. Assignment Creation & AI Permission Configuration
Instructors define AI assistance policies in plain language (e.g., *"Do not write code for the student — only provide hints and ask guiding questions"*). These constraints are encoded into the system prompt for every student interaction on that assignment.

### 2. AI Interaction Logs Viewer
Faculty can view the full chronological record of every student-AI exchange. Two LLM-powered agents (built with LangChain) reduce the review overhead:

- **Flagging Agent** — Evaluates each exchange against the instructor's policy and flags interactions that may raise academic integrity concerns.
- **Summary Agent** — Produces a concise 2–3 sentence summary per student per assignment, covering what the student used the AI for, whether usage was appropriate, and any exchanges warranting closer attention.

### 3. Process-Based Grading Panel
Allows faculty to view a student's final submission alongside their full interaction log, supporting process-oriented grading that considers *how* the student engaged with the material, not just what they submitted.

---

## Evaluation

The system was evaluated over approximately three weeks with two undergraduate students (P1 and P2) enrolled in a foundational CS course at Ashesi University. Both had limited prior experience with AI-assisted programming tools. Participants completed a single assignment — the Student Grade Analyser — entirely within the Student IDE, using only the integrated StudentChat assistant.

### Data Sources
- **AI Interaction Logs** — Full timestamped prompt-and-response records for every student-AI exchange
- **Post-Survey** — Administered immediately after submission; revisited self-efficacy, AI attitude, and task experience items
- **Reflection Survey** — Administered several days after submission; captured more deliberate retrospective judgements about learning and independence

### Key Findings

**SBQ2 (Faculty Evidence):** Interaction logs provided qualitatively richer evidence than submitted code alone. P1's log showed a mix of error-driven and conceptually motivated prompts, with error types shifting from structural to logical issues over time — a signal of developing understanding. P2's log revealed 12 exchanges driven almost entirely by runtime errors (NameError, ValueError, IndexError, TypeError, loop indexing), with the student consistently returning to their code independently between prompts. This attempt → fail → return → attempt again sequence is visible only in the interaction log, not the submitted solution. Post-survey responses (Q14) confirmed that neither participant copied AI responses directly — P1 partially adapted responses; P2 read, understood, and then wrote their own version.

**SBQ3 (Student Understanding):** Reflection survey responses indicated that both participants perceived the constrained AI environment as having encouraged genuine understanding. P2 rated the system 5/5 for independent thinking, reported relying on AI *less* than usual, and drew an explicit contrast with ChatGPT: *"[ChatGPT] tells you exactly what to do by giving you the exact answer [but the Student IDE] helped show where you made a mistake so you work on it."* Both participants independently affirmed the system encourages genuine understanding of programming concepts.

---

## Limitations

- Small sample size (2 participants); findings are not statistically generalisable
- Single institution, single assignment session — limits conclusions about longer-term learning outcomes
- No formal comparative condition (parallel group using unrestricted AI tools)
- Adaptive engine currently uses conversation history rather than real-time performance scoring
- Removing copy-paste functionality entirely introduced friction without proportionate pedagogical benefit
- Current LLM (Groq / Llama 3.3 70B) may not meet reliability requirements for broader institutional deployment

---

## Future Work

- **UI & Onboarding** — Redesign navigation for students unfamiliar with VS Code; replace copy-paste blocking with logging-based approach
- **Adaptive Engine** — Incorporate real-time performance scoring (error frequency, help-seeking patterns) to dynamically adjust scaffolding; add code snapshot functionality to capture solution evolution
- **LLM Upgrade** — Evaluate with GPT-4 or Claude for improved response quality and scalability; add highlight-to-chat feature for contextually precise interactions
- **Evaluation** — Full cohort study across multiple assignments; comparative study design; include faculty participants using the Instructor Dashboard in a real grading context

---

## Project Structure

This repository uses Git submodules. Clone with:

```bash
git clone --recurse-submodules https://github.com/baaba-midnight/CAPSTONE_BOA
```

```
backend/               # 🔗 github.com/baaba-midnight/capstoneBackend
  app/
    routes/            # API endpoints
    services/          # Business logic and LLM orchestration
    agents/            # Flagging and Summary LangChain agents
  README.md            # Backend setup and run instructions

instructor-dashboard/  # 🔗 github.com/baaba-midnight/instructor-dashboard
  src/
    ...                # Dashboard web application
  README.md            # Dashboard setup and run instructions

student-ide/           # 🔗 github.com/baaba-midnight/student-ide
  ...                  # VS Code OSS extension and Electron packaging
```

| Submodule | Repository |
|---|---|
| Backend | [baaba-midnight/capstoneBackend](https://github.com/baaba-midnight/capstoneBackend/tree/8ba58d28c252d98db51a352d9d9e4700499ce13c) |
| Student IDE | [baaba-midnight/student-ide](https://github.com/baaba-midnight/student-ide/tree/d875d4501fa54f555ae598df15e165aaf45071e9) |
| Instructor Dashboard | [baaba-midnight/instructor-dashboard](https://github.com/baaba-midnight/instructor-dashboard/tree/ad756cce6d1610672e3867c49f7d8f356e396235) |

See `backend/README.md` and `instructor-dashboard/README.md` for setup and run instructions.

---

## Acknowledgements

Supervised by **Dennis A. Owusu**, Ashesi University.
Submitted in partial fulfilment of the requirements for the Bachelor of Science in Computer Science, Ashesi University, 2026.