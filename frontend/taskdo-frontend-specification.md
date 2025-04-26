# Taskdo Frontend Specification

## 1. Overview

The Taskdo frontend will be built with Flutter and designed as a desktop-first application with mobile adaptability. It will provide an intuitive and responsive user interface for the productivity management application, integrating with the FastAPI backend.

## 2. Technology Stack

- **Framework**: Flutter 3.x
- **State Management**: flutter_bloc
- **HTTP Client**: Dio
- **Storage**: Secure Storage for token management
- **Navigation**: Go Router
- **UI Components**: Flutter Material Design
- **Charts and Analytics**: fl_chart
- **Date/Time Handling**: intl
- **Responsive Design**: LayoutBuilder, MediaQuery, and adaptive layouts
- **Internationalization**: Flutter Intl package (optional for future)
- **Testing**: Flutter Test, Mockito

## 3. Project Structure

```
frontend/
│
├── lib/
│   ├── main.dart                  # Application entry point
│   │
│   ├── config/                    # Application configuration
│   │   ├── routes.dart            # Route definitions
│   │   ├── themes.dart            # Theme configuration
│   │   └── constants.dart         # Application constants
│   │
│   ├── data/                      # Data layer
│   │   ├── models/                # Data models
│   │   │   ├── user.dart
│   │   │   ├── project.dart
│   │   │   ├── task.dart
│   │   │   ├── tag.dart
│   │   │   └── pomodoro.dart
│   │   │
│   │   ├── repositories/          # Repository implementations
│   │   │   ├── auth_repository.dart
│   │   │   ├── project_repository.dart
│   │   │   ├── task_repository.dart
│   │   │   ├── tag_repository.dart
│   │   │   └── pomodoro_repository.dart
│   │   │
│   │   └── providers/             # Data providers/services
│   │       ├── api_provider.dart   # API client
│   │       ├── secure_storage.dart # Secure storage service
│   │       └── analytics_service.dart # Analytics service
│   │
│   ├── blocs/                     # BLoC state management
│   │   ├── auth/                  # Authentication bloc
│   │   ├── projects/              # Projects bloc
│   │   ├── tasks/                 # Tasks bloc
│   │   ├── tags/                  # Tags bloc
│   │   ├── pomodoro/              # Pomodoro bloc
│   │   └── settings/              # Settings bloc
│   │
│   ├── screens/                   # Application screens
│   │   ├── auth/                  # Authentication screens
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   ├── verification_screen.dart
│   │   │   └── password_reset_screen.dart
│   │   │
│   │   ├── onboarding/            # Onboarding screens
│   │   │   └── onboarding_screen.dart
│   │   │
│   │   ├── dashboard/             # Main dashboard
│   │   │   └── dashboard_screen.dart
│   │   │
│   │   ├── projects/              # Project screens
│   │   │   ├── projects_list_screen.dart
│   │   │   ├── project_detail_screen.dart
│   │   │   └── project_form_screen.dart
│   │   │
│   │   ├── tasks/                 # Task screens
│   │   │   ├── tasks_list_screen.dart
│   │   │   ├── task_detail_screen.dart
│   │   │   └── task_form_screen.dart
│   │   │
│   │   ├── tags/                  # Tag screens
│   │   │   ├── tags_list_screen.dart
│   │   │   └── tag_form_screen.dart
│   │   │
│   │   ├── pomodoro/              # Pomodoro screens
│   │   │   └── pomodoro_screen.dart
│   │   │
│   │   ├── reports/               # Reporting screens
│   │   │   └── reports_screen.dart
│   │   │
│   │   └── settings/              # Settings screens
│   │       └── settings_screen.dart
│   │
│   ├── widgets/                   # Reusable widgets
│   │   ├── common/                # Common widgets
│   │   ├── auth/                  # Authentication widgets
│   │   ├── projects/              # Project widgets
│   │   ├── tasks/                 # Task widgets
│   │   ├── tags/                  # Tag widgets
│   │   ├── pomodoro/              # Pomodoro widgets
│   │   └── reports/               # Report widgets
│   │
│   └── utils/                     # Utility classes
│       ├── validators.dart        # Form validators
│       ├── formatters.dart        # Formatters
│       ├── date_utils.dart        # Date utilities
│       └── error_handler.dart     # Error handling
│
├── assets/                        # Application assets
│   ├── images/                    # Image assets
│   ├── fonts/                     # Font assets
│   └── icons/                     # Icon assets
│
├── test/                          # Tests
│   ├── unit/                      # Unit tests
│   ├── widget/                    # Widget tests
│   └── integration/               # Integration tests
│
└── pubspec.yaml                   # Dependencies
```

## 4. Screen Designs and User Flows

### 4.1. Authentication Screens

#### 4.1.1. Login Screen
- Email and password input fields
- Login button
- "Forgot password" link
- "Register" link
- Error display for invalid credentials
- Loading state during authentication

#### 4.1.2. Registration Screen
- Email and password input fields
- Password confirmation field
- Register button
- "Login" link for existing users
- Error display for validation issues
- Success state prompting for email verification

#### 4.1.3. Email Verification Screen
- Verification code input field
- Verification button
- Resend code option
- Error display for invalid codes
- Success state and auto-navigation to dashboard

#### 4.1.4. Password Reset Screen
- Email input for requesting reset
- Verification code input (after reset request)
- New password and confirmation fields
- Reset button
- Success state with navigation to login

### 4.2. Onboarding Flow

- Initial project creation guidance
- Introduction to key features (projects, tasks, Pomodoro)
- Quick tips for getting started
- Option to skip onboarding
- Progress indicators
- "Next" and "Back" navigation

### 4.3. Dashboard Screen

- Overview of current tasks
- Active Pomodoro timer (if running)
- Project summary
- Recent activity
- Quick actions (create task, start Pomodoro, etc.)
- Navigation to other sections

### 4.4. Project Management Screens

#### 4.4.1. Projects List Screen
- Grid/list view of all projects
- Color-coding for projects
- Project creation button
- Project cards with:
  - Project name
  - Task count/completion status
  - Deadline indicator
  - Color indicator
- Filter options (active, archived)
- Search functionality

#### 4.4.2. Project Detail Screen
- Project header with name, description, deadline
- Tasks list filtered by the project
- Task creation button
- Task sorting and filtering
- Progress indicators
- Edit and archive project options
- Back navigation

#### 4.4.3. Project Form Screen
- Fields for name, description, color selection, deadline
- Validation for required fields
- Save and cancel buttons
- Delete option (for editing existing projects)

### 4.5. Task Management Screens

#### 4.5.1. Tasks List Screen
- List view of tasks with:
  - Task name
  - Project association
  - Priority indicator
  - Due date
  - Status indicator
- Filter options (by project, status, priority)
- Sort options (due date, priority, creation date)
- Search functionality
- Task creation button

#### 4.5.2. Task Detail Screen
- Task header with name, project, and priority
- Due date and time display
- Estimated and completed Pomodoros
- Tags display
- Notes section
- Subtasks list with completion toggles
- Edit and delete options
- Start Pomodoro button
- Back navigation

#### 4.5.3. Task Form Screen
- Fields for:
  - Name
  - Project selection (dropdown)
  - Estimated Pomodoros
  - Due date and time picker
  - Priority selection
  - Tag selection (multi-select)
  - Notes input
  - Subtasks management
- Validation for required fields
- Due date validation based on estimated Pomodoros
- Save and cancel buttons
- Delete option (for editing existing tasks)

### 4.6. Tag Management Screens

#### 4.6.1. Tags List Screen
- Grid/list view of tags with:
  - Tag name
  - Color indicator
  - Associated task count
- Tag creation button
- Search functionality

#### 4.6.2. Tag Form Screen
- Fields for name and color selection
- Validation for required fields
- Save and cancel buttons
- Delete option (for editing existing tags)

### 4.7. Pomodoro Screens

#### 4.7.1. Pomodoro Screen
- Large timer display
- Selected task display
- Start/pause/cancel buttons
- Skip break option
- Focus mode toggle
- Session progress (e.g., "Pomodoro 2 of 4")
- Session type indicator (work/break)
- Next scheduled break/work session
- Mini task list for quick task selection
- Session history

### 4.8. Reporting Screens

#### 4.8.1. Reports Screen
- Date range selector
- Summary statistics:
  - Total focus time
  - Completed Pomodoros
  - Tasks completed
  - Projects completed
- Charts and visualizations:
  - Focus time by day
  - Task completion rate
  - Project time distribution
  - Task chart (visualization of tasks)
- Filtering options (by project, tag, etc.)
- Export options (for future implementation)

### 4.9. Settings Screen

- User profile section
- Application settings:
  - Pomodoro duration settings
  - Notification preferences
  - Focus mode settings
- Account management
- Logout option

## 5. State Management with BLoC Pattern

### 5.1. Authentication Bloc
- States: Initial, Loading, Authenticated, Unauthenticated, VerificationRequired, Error
- Events: Login, Register, Verify, RequestPasswordReset, ResetPassword, Logout

### 5.2. Projects Bloc
- States: Initial, Loading, Loaded, Error
- Events: LoadProjects, CreateProject, UpdateProject, ArchiveProject, FilterProjects

### 5.3. Tasks Bloc
- States: Initial, Loading, Loaded, Error
- Events: LoadTasks, CreateTask, UpdateTask, DeleteTask, UpdateTaskStatus, FilterTasks

### 5.4. Tags Bloc
- States: Initial, Loading, Loaded, Error
- Events: LoadTags, CreateTag, UpdateTag, DeleteTag

### 5.5. Pomodoro Bloc
- States: Initial, Ready, Running, Paused, Break, Completed, Cancelled, Error
- Events: StartPomodoro, PausePomodoro, ResumePomodoro, CompletePomodoro, CancelPomodoro, SkipBreak, StartBreak, CompleteBreak

### 5.6. Settings Bloc
- States: Initial, Loading, Loaded, Error
- Events: LoadSettings, UpdateSettings, ResetSettings

## 6. Data Models

### 6.1. User Model
```dart
// Representation of User data model
class User {
  final String id;
  final String email;
  final bool isVerified;
  final DateTime createdAt;

  // Constructor and other methods
}
```

### 6.2. Project Model
```dart
// Representation of Project data model
class Project {
  final String id;
  final String name;
  final String description;
  final String color;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;

  // Constructor and other methods
}
```

### 6.3. Task Model
```dart
// Representation of Task data model
class Task {
  final String id;
  final String projectId;
  final String name;
  final int estimatedPomodoros;
  final int completedPomodoros;
  final DateTime dueDate;
  final String priority;
  final List<String> tags;
  final String status;
  final String notes;
  final List<Subtask> subtasks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final bool isDeleted;

  // Constructor and other methods
}

class Subtask {
  final String description;
  final bool completed;

  // Constructor and other methods
}
```

### 6.4. Tag Model
```dart
// Representation of Tag data model
class Tag {
  final String id;
  final String name;
  final String color;
  final DateTime createdAt;

  // Constructor and other methods
}
```

### 6.5. Pomodoro Session Model
```dart
// Representation of Pomodoro Session data model
class PomodoroSession {
  final String id;
  final String taskId;
  final DateTime startTime;
  final DateTime endTime;
  final int duration;
  final String type;
  final bool completed;
  final bool interrupted;
  final DateTime createdAt;

  // Constructor and other methods
}
```

## 7. API Integration

### 7.1. API Provider
- Base URL configuration
- API key authentication
- JWT token management
- Request/response interceptors
- Error handling and retries
- Timeout configuration

### 7.2. Repository Pattern
- Implementation of repository interfaces
- API call abstraction
- Caching strategies
- Error handling
- Data transformation

## 8. UI/UX Design Guidelines

### 8.1. Color Palette
- Primary: Coral/Orange (#FF5A5A)
- Secondary: White (#FFFFFF)
- Background: Light Gray (#F5F5F5)
- Text: Dark Gray (#333333)
- Accent Colors:
  - High Priority: Red (#FF3B30)
  - Medium Priority: Orange (#FF9500)
  - Low Priority: Green (#34C759)

### 8.2. Typography
- Headings: SF Pro Display or Roboto (Bold)
- Body Text: SF Pro Text or Roboto (Regular)
- Font Sizes:
  - Heading 1: 24px
  - Heading 2: 20px
  - Heading 3: 18px
  - Body: 16px
  - Small: 14px

### 8.3. UI Components
- Cards: Rounded corners (8px), subtle shadow
- Buttons: Rounded (4px), consistent padding
- Input Fields: Clear labels, validation feedback
- Icons: Material or custom icon set
- Lists: Consistent spacing, dividers as needed
- Navigation: Clear hierarchy, consistent placement

### 8.4. Animation and Transitions
- Subtle page transitions
- Progress indicators for loading states
- Micro-interactions for user feedback
- Smooth state transitions

### 8.5. Responsive Design
- Desktop layout (primary):
  - Multi-column layouts
  - Sidebar navigation
  - Expanded content area
  - Horizontal forms
- Mobile layout (adaptive):
  - Single column layouts
  - Bottom navigation
  - Stacked forms
  - Modal dialogs for detailed views

## 9. Responsive Layout Strategy

### 9.1. Breakpoints
- Mobile: < 600px
- Tablet: 600px - 1200px
- Desktop: > 1200px

### 9.2. Layout Adaptation
- Use LayoutBuilder for responsive widgets
- MediaQuery for device information
- Conditional layouts based on screen size
- Reusable adaptive widgets

### 9.3. Navigation Adaptation
- Desktop: Persistent sidebar navigation
- Mobile: Bottom navigation bar or drawer
- Tablet: Collapsible sidebar or bottom navigation

## 10. Specific Feature Requirements

### 10.1. Authentication
- Secure token storage
- Token refresh mechanism
- Auto-logout on token expiration
- Remember me functionality
- Session management

### 10.2. Pomodoro Timer
- Accurate countdown timer
- Background timer when app is minimized
- System notifications for timer completion
- Session tracking and storage
- Focus mode integration with system DND

### 10.3. Task Due Date Validation
- Calculate minimum due date based on:
  - Current time
  - Estimated Pomodoros
  - Pomodoro duration (25 min default)
  - Break duration (5 min default)
- Display warnings for impossible deadlines
- Suggest alternative due dates

### 10.4. Offline Capabilities (Future Enhancement)
- Local storage of critical data
- Offline actions queue
- Sync when online
- Conflict resolution

## 11. Testing Strategy

### 11.1. Unit Tests
- BLoC testing
- Repository testing
- Utility function testing
- Model testing

### 11.2. Widget Tests
- Component testing
- Screen testing
- Navigation testing
- Form validation testing

### 11.3. Integration Tests
- End-to-end user flows
- API integration testing
- State persistence testing

## 12. Error Handling

### 12.1. User-Facing Errors
- Friendly error messages
- Contextual error handling
- Recovery suggestions
- Critical vs. non-critical error differentiation

### 12.2. Technical Error Handling
- Exception catching
- Error logging
- Crash reporting
- Graceful degradation

## 13. Performance Considerations

### 13.1. Optimization Techniques
- Efficient state management
- Lazy loading of resources
- Widget recycling with ListView.builder
- Memory management
- Image optimization

### 13.2. Startup Performance
- Minimize startup time
- Loading indicators for initial data fetch
- Splash screen design

## 14. Accessibility

### 14.1. Requirements
- Screen reader support
- Sufficient contrast ratios
- Keyboard navigation (desktop)
- Touch targets (mobile)
- Text scaling
- Alternative text for images

## 15. Implementation Roadmap

### Phase 1: Core Structure and Authentication
- Project setup
- Navigation system
- Authentication screens
- Base theme and UI components

### Phase 2: Project and Task Management
- Project management screens
- Task management screens
- Tag management
- Initial responsive design

### Phase 3: Pomodoro Timer and Reporting
- Pomodoro timer implementation
- Focus mode integration
- Reporting screens
- Analytics implementation

### Phase 4: Polish and Optimization
- UI/UX refinement
- Performance optimization
- Error handling improvements
- Accessibility enhancements
- Cross-platform testing

## 16. Future Enhancements
- Offline support
- Data export/import
- Advanced analytics
- Team collaboration features
- Calendar integration
- Third-party integrations
