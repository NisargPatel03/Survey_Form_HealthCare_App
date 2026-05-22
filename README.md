# 🏥 Clinical Health Care Survey & Academic Evaluation Platform
### *A Tri-System Digital Platform for Nursing Surveys, Academic Submissions, & Enterprise Administration*

---

## 📌 Project Overview
This platform is a state-of-the-art academic and clinical solution developed for the **Manikaka Topawala Institute of Nursing (MTIN)**, a constituent of **CHARUSAT (Changa, Gujarat)**. It is designed to modernise, stream, and digitise the extensive fieldwork and clinical requirements mandated in the **Community Health Nursing - I & II (NUR 303 & NUR 401)** courses.

The platform replaces complex paper-based baseline clinical surveys, physical architectural layout drawings, and manual evaluation marks sheets with a unified, real-time sync system that works flawlessly in offline-first community settings and synchronizes with interactive web portals for faculty evaluation and administrative control.

---

## 🔄 Tri-System System Architecture

The platform operates as three decoupled client applications communicating through a secure, unified **Supabase Cloud Backend**:

```
                              ┌──────────────────────────────────────────────┐
                              │           📱 FLUTTER MOBILE APP              │
                              │       (Nursing Student Client Terminal)      │
                              └──────────────────────┬───────────────────────┘
                                                     │
                                                     ▼ (Dynamic Forms & Sketches)
┌────────────────────────────────────────────────────┼────────────────────────────────────────────────────┐
│                                           ☁️ SUPABASE BACKEND                                          │
│                                                                                                        │
│  ┌───────────────────────┐        ┌───────────────────────────────────┐        ┌────────────────────┐  │
│  │   🔐 AUTHENTICATION   │        │     📊 POSTGRESQL DATABASE        │        │   📂 OBJECT STORE  │  │
│  │                       │        │                                   │        │  (Sketches & Maps) │  │
│  │  - User Auth Logins   │        │  - Profiles (Admin/Faculty/Stud)  │        │                    │  │
│  │  - Custom Admin RLS   │        │  - Submissions (Dynamic JSONB)    │        │  - requirement-    │  │
│  │                       │        │  - Surveys (Baseline data)        │        │    attachments     │  │
│  └───────────────────────┘        └───────────────────────────────────┘        └────────────────────┘  │
└───────▲────────────────────────────────────────────▲────────────────────────────────────▲────────────────┘
        │                                            │                                    │
        │ (Data Audits & Access)                     │ (Grades, Remarks & approvals)      │ (Attachments Access)
┌───────┴──────────────────────┐            ┌────────┴─────────────────────┐            ┌─┴──────────────────┐
│      ⚙️ REACT ADMIN PANEL    │            │     💻 REACT FACULTY PANEL   │            │   📂 PUBLIC CLIENT │
│ (Admin Control & Analytics)  │            │ (Faculty Evaluator Terminal) │            │  (Public Records)  │
└──────────────────────────────┘            └──────────────────────────────┘            └────────────────────┘
```

### 1. 📱 Student Mobile App (Flutter Client)
*   **Offline-First Core:** Runs a local draft database utilizing **SharedPreferences** for immediate data caching, and an optional **SQLite** database helper. If the student has zero network coverage during field surveys, the application works normally and files are cataloged locally.
*   **Dynamic UI Builder:** Rather than hardcoding 57 individual forms, a dynamic parser parses a target JSON schema depending on the course and requirement serial number. It automatically generates validation fields, text areas, input pickers, dropdown boxes, and sketch modules.
*   **Interactive Vector Painter:** A native Flutter paint component (`SketchCanvasScreen`) captures touch gestures, computes coordinates, renders vectors, and compiles the finalized graphic layout into high-resolution PNG data.
*   **Supabase Attachment Sync (`AttachmentService`):** Converts drawing arrays to files, segmenting their cloud paths securely (e.g., `requirements/{studentId}/{reqSrNo}/sketch_{timestamp}.png`), and uploads them to Supabase Storage, updating local links dynamically.

### 2. 💻 Faculty Evaluation Panel (React Web App)
*   **Semester-grouped Submissions:** Submissions from students are pulled in real-time, grouped automatically by **Semester 5 (NUR 303)** and **Semester 7 (NUR 401)**, and mapped under individual student card portfolios.
*   **Interactive Sketch Viewer:** Displays hand-drawn physical layouts side-by-side with student text answers. Features dynamic hover zoom scales, interactive glass overlays, and fullscreen download triggers.
*   **Strict Criteria Validation:** Ensures academic evaluation integrity. It prevents approval submissions if any marks input columns are blank, displaying an alerts box with the exact criteria missing a score.
*   **Cumulative PDF Compiler:** Once a student completes all required forms, the web panel compiles a multipage **Cumulative Clinical Record PDF** using `jsPDF` and `autoTable`, with striped tables, grading metrics, and signature indicators.

### 3. ⚙️ Admin Panel Dashboard (React Web App)
*   **Central Administration Hub:** Displays high-level dashboard metrics tracking active surveyor numbers, total family surveys collected, and pending requirement approvals.
*   **Demographic Analytics (`Analytics.jsx`):** Dynamically parses and aggregates survey responses to compile comparative charts representing religions, housing structures, water supplies, and economic classifications.
*   **Student Academic Records (`StudentAcademicRecords.jsx`):** Grid mapping student clinical portfolios, showing completed requirements, evaluation states, marks, and enabling direct updates.
*   **Surveyor Performance Audits (`SurveyorAnalytics.jsx`):** Visualizes surveyor upload timelines, frequencies, active hours, and total submission efficiency.
*   **Geographical Mapping (`MapHealth.jsx`):** Pinpoints community health hotspots, mapping environmental cleanlines, disease cases, and resource demands spatially.
*   **Custom Report Builder (`ReportBuilder.jsx`):** Enables custom-headed administrative reports compiled on-demand from real-time PostgreSQL data.
*   **Data Portability (`Export.jsx` & `FamilyDirectory.jsx`):** Directory lists of heads of households and secure bulk-export format files for backup or external research analysis.

---

## 📐 Dynamic Schema & Academic Requirements

The dynamic form engine handles requirements for both academic years by parsing static JSON schemas stored in the assets directories:

### 📘 NUR 303 (5th Semester) - 22 Dynamic Requirements
Core requirements represent orientation reviews, household studies, school assessments, and health talks:
*   **Orientation Reports (1.1, 7.1):** Summarizes SC, PHC, CHC, and Anganwadi structural guidelines.
*   **Family Care Plan & Study (2.1, 3.1, 8.1, 9.1):** Tracks multi-visit home assessment parameters.
*   **Group Health Talks (5.1):** Outlines educational objectives, AV aids, and attendance metrics.
*   **School Health Program (6.1):** Collects children health reports, physical assessment metrics, and hygiene checks.
*   **Anganwadi Assessment Report (6.2):** High-priority template containing structural assessments, child malnutrition counts, and **Physical Layout Sketch maps**.
*   **Survey Report (6.3):** Core baseline family survey records.
*   **Clinical Performance Evaluation (13.1 - 13.6):** Continuous performance cards.

### 📙 NUR 401 (7th Semester) - 35 Dynamic Requirements
Features advanced clinical nursing orientations, mocks drills, and role-plays:
*   **Orientation & Visit Reports (12.1 - 12.4):** Summarizes academic orientations to rural health systems.
*   **Disaster Mock Drill (11.1):** Tracks participation logs and protocol validation reports.
*   **Interaction with Health Workers (6.1, 6.2):** Documents collaborative nursing reports.
*   **Role-Play Formats (12.1 - 12.4):** Evaluates educational dramaturgy topics in communities.

---

## 🎨 Vector Canvas Engine (`SketchCanvasScreen`)

The sketch canvas uses advanced real-time gesture coordinate mapping. The engine operates on mathematical shapes connecting discrete points:

```
    Brush Stroke:  Point(x1, y1) ────► Point(x2, y2) ────► Point(x3, y3)
    Straight Line: StartPoint(x1, y1) ───────────────────► EndPoint(x2, y2)
    Rectangle:     StartPoint(x1, y1) ──┐
                   │                    │  Bounding Rect.fromPoints()
                   └────────────────────► EndPoint(x2, y2)
    Circle/Oval:   StartPoint(x1, y1) ──┐
                   │   O                │  Bounding Oval.fromPoints()
                   └────────────────────► EndPoint(x2, y2)
```

### 1. State Tracking Architecture
```dart
Offset _startPoint = Offset.zero;                      // First contact point
String _activeTool = 'brush';                         // Mode: brush, line, rectangle, circle
List<DrawingPath> _paths = [];                         // Vector paths layer
List<TextLabel> _labels = [];                          // Canvas room annotations text labels
```

### 2. Math & Canvas Generation Logic
*   **Brush Strokes:** Traces standard contiguous arrays:
    ```dart
    _paths.last.path.lineTo(details.localPosition.dx, details.localPosition.dy);
    ```
*   **Perfect Straight Lines:** Traces vector bounds between initial tap and release coordinates:
    ```dart
    newPath.lineTo(details.localPosition.dx, details.localPosition.dy);
    ```
*   **Rectangles (Room Layout bounds):** Traces standard closed squares:
    ```dart
    newPath.addRect(Rect.fromPoints(_startPoint, details.localPosition));
    ```
*   **Circles (Pillars & Columns):** Traces ovals within boundary boxes:
    ```dart
    newPath.addOval(Rect.fromPoints(_startPoint, details.localPosition));
    ```
*   **Text Annotations:** Renders high-contrast, self-centering text labels using `TextPainter` with solid backgrounds to preserve readability against multi-colored vectors.

---

## ⚙️ Detailed Installation & Setup

Follow these precise instructions to deploy both the mobile client and the web console on a fresh development system:

### 📱 Dynamic Mobile App Installation (Flutter)

1.  **Clone the Project:**
    ```bash
    git clone <repository-url>
    cd Community_Health_Care_Survey
    ```
2.  **Verify Flutter Installation:**
    Ensure you are on the stable channel:
    ```bash
    flutter doctor
    ```
3.  **Fetch Pub Dependencies:**
    Installs dynamic vector managers, local preferences, and image pickers:
    ```bash
    flutter pub get
    ```
4.  **Configure local environment credentials:**
    Open `lib/main.dart` and initialize the Supabase client:
    ```dart
    await Supabase.initialize(
      url: 'YOUR_SUPABASE_PROJECT_URL',
      anonKey: 'YOUR_SUPABASE_ANON_KEY',
    );
    ```
5.  **Run Client:**
    ```bash
    flutter run
    ```

---

### 💻 Faculty Console Installation (React)

1.  **Navigate to directory:**
    ```bash
    cd faculty_panel_react
    ```
2.  **Install dynamic dependencies:**
    Installs Tailwind styles, jsPDF dynamic compilers, and lucide vectors:
    ```bash
    npm install
    ```
3.  **Configure environment values:**
    Create a `.env` file in the root of `faculty_panel_react/`:
    ```env
    VITE_SUPABASE_URL=https://YOUR_SUPABASE_PROJECT_ID.supabase.co
    VITE_SUPABASE_ANON_KEY=YOUR_SUPABASE_SECRET_ANON_KEY
    ```
4.  **Start Development server:**
    ```bash
    npm run dev
    ```
    *The dashboard console is loaded at `http://localhost:5173`.*

---

### ⚙️ Admin Panel Installation (React)

1.  **Navigate to the admin console directory:**
    ```bash
    cd admin_panel_react
    ```

2.  **Install admin packages:**
    Installs analytics libraries, Tailwind design tokens, and authentication models:
    ```bash
    npm install
    ```

3.  **Configure environment secrets:**
    Create a `.env` file in the root of `admin_panel_react/`:
    ```env
    VITE_SUPABASE_URL=https://YOUR_SUPABASE_PROJECT_ID.supabase.co
    VITE_SUPABASE_ANON_KEY=YOUR_SUPABASE_SECRET_ANON_KEY
    ```

4.  **Run Dev Web Server:**
    ```bash
    npm run dev
    ```
    *The admin console dashboard will run locally at `http://localhost:5173` (or the next available port).*

---

## 🤝 Clinical Affiliation & Educational Intent

This digital platform was designed under the guidance of clinical supervisors:
*   **Affiliation:** Manikaka Topawala Institute of Nursing (MTIN), CHARUSAT.
*   **Course Directives:** Community Health Nursing Fieldwork (NUR 303 & NUR 401).
*   **Objective:** To empower nursing graduates with modern clinical survey methodologies and ensure accurate, structured evaluation templates for faculty examiners.
