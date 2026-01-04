# Community Health Care Survey

A Flutter application for conducting baseline health surveys in community health care settings. This app is based on the baseline survey form from Manikaka Topawala Institute of Nursing, CHARUSAT - Campus, Changa.

## Features

- ✅ Complete survey form matching the baseline survey questionnaire exactly
- ✅ All 39 sections from the original PDF form
- ✅ Form validation for required fields
- ✅ Multi-section navigation with progress indicator
- ✅ Data storage using local storage (SharedPreferences)
- ✅ Export functionality (CSV and JSON formats)
- ✅ Admin dashboard to view all submitted responses
- ✅ Detailed survey view for each submission
- ✅ Mobile-friendly UI with Material Design 3

## Survey Sections Included

The app includes all sections from the baseline survey form:

1. **Basic Information** - Area, Health Centre, Head of Family, Family Type, Religion
2. **Housing Condition** - Type, Rooms, Occupancy, Ventilation, Lighting, Water Supply, Kitchen, Drainage, Lavatory
3. **Family Composition** - Complete family member details with dynamic addition
4. **Income & Socio-economic** - Total income and classification
5. **Transport & Communication** - Transport options, communication media, languages
6. **Dietary Pattern** - Food availability, usage, and preparation methods
7. **Expenditure Statement** - Detailed family expenditure breakdown
8. **Health Conditions** - Fever, Skin Diseases, Cough, Other Illnesses
9. **Family Health Attitude** - Knowledge, beliefs, and health service utilization
10. **Pregnant Women** - Gravida, registration, iron/folic acid, tetanus toxoid
11. **Vital Statistics** - Births, Deaths, Marriages (within one year)
12. **Immunization** - Children below 5 years immunization records
13. **Eligible Couples** - Family planning priorities and methods
14. **Malnutrition** - Children 0-5 years malnutrition assessment
15. **Environmental Health** - Sewage, waste, excreta disposal, water sources, cleanliness
16. **Health Services** - Treatment locations, health agencies, insurance
17. **Family Assessment** - Strengths, weaknesses, national health programmes
18. **Final Details** - Contact number, survey date, student information

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android Emulator or physical device / iOS Simulator or device

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd Community_Health_Care_Survey
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Building for Release

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── survey_data.dart     # Data models for survey
├── screens/
│   ├── survey_form_screen.dart      # Main survey form
│   ├── admin_dashboard_screen.dart   # View all submissions
│   └── survey_detail_screen.dart     # View single survey details
├── services/
│   └── storage_service.dart  # Data persistence service
└── widgets/
    ├── survey_sections.dart  # Survey form sections 1-5
    ├── survey_sections_2.dart # Survey form sections 6-9
    ├── survey_sections_3.dart # Survey form sections 10-12
    ├── survey_sections_4.dart # Survey form sections 13-15
    └── survey_sections_5.dart # Survey form sections 16-18
```

## Usage

### Creating a New Survey

1. Launch the app
2. Tap "Start New Survey" on the home screen
3. Navigate through all 18 sections using Next/Previous buttons
4. Fill in all required fields (marked with validation)
5. Submit the survey when complete

### Viewing Submissions

1. Tap "View Submissions" on the home screen
2. Browse all submitted surveys
3. Tap any survey to view detailed information
4. Use the menu to export data (CSV/JSON) or delete surveys

### Exporting Data

1. Go to Admin Dashboard
2. Tap the menu icon (three dots)
3. Select "Export to CSV" or "Export to JSON"
4. Files are saved to the app's documents directory

## Data Storage

- All survey data is stored locally using SharedPreferences
- Data persists across app restarts
- Export files are saved to the device's documents directory

## Dependencies

- `flutter` - Flutter SDK
- `shared_preferences` - Local data storage
- `path_provider` - File system access
- `csv` - CSV export functionality
- `intl` - Date formatting
- `file_picker` - File operations

## Notes

- All survey fields match the original PDF form exactly
- No questions or fields have been added or removed
- The form maintains the original order and grouping
- Validation ensures data quality
- The app works offline (no internet connection required)

## License

This project is created for educational purposes as part of the Community Health Nursing course.

## Credits

Based on the baseline survey form from:
**Manikaka Topawala Institute of Nursing**
**CHARUSAT - Campus, Changa**
**Community Health Nursing - I**

