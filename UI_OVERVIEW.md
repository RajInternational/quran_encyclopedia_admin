# Quran Encyclopedia Admin - UI Overview

## Application Flow

### 1. **Entry Point (main.dart)**
- App starts with `SplashScreen` (2-second delay)
- Uses Firebase for backend (Firestore & Auth)
- Theme: Supports dark/light mode via MobX store
- Primary color: Green (#1C721E)

### 2. **Splash Screen → Dashboard**
- Shows app logo and name
- After 2 seconds:
  - If logged in → Goes to `AdminDashboardScreen`
  - If not logged in → **Currently bypasses login** and goes directly to `AdminDashboardScreen` (line 30)

### 3. **Admin Login Screen** (Currently Bypassed)
- Simple email/password form
- Hardcoded credentials: `user@admin.com` / 8 spaces
- On success → Navigates to `AdminDashboardScreen`

### 4. **Admin Dashboard Screen** (Main UI)
**Layout Structure:**
```
┌─────────────────────────────────────────────────────┐
│ AppBar: "Quran Encyclopedia Admin"                  │
├──────────┬──────────────────────────────────────────┤
│          │                                          │
│ Sidebar  │  Main Content Area                       │
│ (15%)    │  (84%)                                   │
│          │                                          │
│ Drawer   │  Current Widget                          │
│ Widget   │  (SubjectDetailScreen by default)        │
│          │                                          │
└──────────┴──────────────────────────────────────────┘
```

**Sidebar Navigation (DrawerWidget):**
- **View Subject** - Shows paginated list of Quran subjects with ayats
- **Add Subject** - Form to create new subjects with ayat references

**Visual Design:**
- Sidebar: Dark green background (colorPrimary)
- Main area: Light gray background (selectedDrawerViewColor)
- Selected menu item: Highlighted with white background
- Rounded corners on menu items

### 5. **Subject Detail Screen** (Default View)
**Features:**
- **Pagination**: 8 subjects per page
- **Display**: Each subject shows:
  - Subject name (in Urdu Nastaliq font)
  - Subject count number
  - Action buttons: Delete, View, Edit
- **Pagination Controls**:
  - Previous/Next buttons
  - Page number buttons (shows 8 pages at a time)
  - Jump to page input field
  - Shows "Page X of Y" info

**Data Structure:**
- Fetches from Firestore: `Book/Quran/SubjectCollection`
- Each subject has a subcollection `ayats` containing Quran verses
- Ordered by `count` field

### 6. **Add Subject Screen (FormScreen)**
**Form Fields:**
- Subject Name (required, min 3 chars)
- Multiple Ayat input fields (format: `Surah.Ayat`, e.g., `2.255`)
- Dynamic fields: Can add/remove ayat input fields

**Workflow:**
1. Enter subject name
2. Enter ayat numbers (one per field)
3. Click "Find Surah & Ayat" → Fetches data from Firestore and shows preview
4. Preview shows:
   - Surah name
   - Ayat number
   - Arabic text
   - Error indicators for missing ayats
5. Click "Create Subject" → Saves to Firestore

**Validation:**
- Subject name required
- Ayat format must be `Surah.Ayat` (e.g., `1.1`, `2.255`)
- No duplicate ayat numbers allowed
- Shows warnings for missing ayats

## UI Components & Styling

### Color Scheme:
- **Primary**: Green (#1C721E)
- **Background**: White/Light gray
- **Selected Items**: Light gray (#F1F5F8)
- **Dark Mode**: Supported (scaffoldSecondaryDark)

### Typography:
- **Urdu/Arabic**: Noto Nastaliq Urdu font
- **English**: Default system font
- **Headings**: Bold, various sizes

### Common UI Patterns:
- **Cards**: White background, rounded corners, shadow
- **Buttons**: Primary color background, white text
- **Input Fields**: Standard Material Design
- **Icons**: Material Icons
- **Loading States**: CircularProgressIndicator
- **Empty States**: Icon + message + action button

## Navigation Pattern

Uses **LiveStream** for sidebar navigation:
- When menu item clicked → Emits `selectItem` event with index
- DrawerWidget listens and updates selected state
- Main content area switches widget based on selection

## Data Management

### Firebase Collections:
1. `Book/Quran/SubjectCollection` - Subjects
2. `Book/Quran/CompleteQuran` - Full Quran data

### State Management:
- **MobX** (AppStore) for global state (theme, user, etc.)
- **Local State** (setState) for component-specific state
- **BLoC** (PaginationCubit) for pagination state

## Current Issues/Observations:

1. **Login Bypassed**: SplashScreen always goes to dashboard (line 30)
2. **Hardcoded Credentials**: Login has hardcoded email/password
3. **Default View**: Dashboard starts with SubjectDetailScreen
4. **Pagination**: Subject list uses custom pagination (8 per page)

