# JOBY

**A Gamified Recruitment Platform for Mobile**
---
[JOBY Website](https://joby-site.vercel.app/)
---
<img width="1080" height="710" alt="joby" src="https://github.com/user-attachments/assets/f56a3658-1c08-4f2c-bc61-6de0aea4ba79" />

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Technology Stack](#technology-stack)
3. [Module A -- Job Seeker (Talent) Application](#module-a----job-seeker-talent-application)
4. [Module B -- Company (Employer) Application](#module-b----company-employer-application)
5. [Architecture Overview](#architecture-overview)
6. [Installation and Setup](#installation-and-setup)

---

## Executive Summary

JOBY is an enterprise-grade, cross-platform mobile application built with Flutter that reimagines the recruitment process through gamification and intelligent profile matching. The platform serves two distinct user personas -- **job seekers** and **employers** -- within a single unified codebase, each receiving a purpose-built experience tailored to their workflow.

Job seekers benefit from a gamified engagement model (points, badges, streaks, and confetti-driven reward feedback), rich smart profiles with geolocation, CV attachment, and social media integration, and a fully functional offline mode that ensures uninterrupted access. Employers gain access to a comprehensive talent discovery engine with advanced filtering, a candidate pipeline with save-and-shortlist capabilities, and detailed talent profile previews.

The application is architected around **Clean Architecture** principles, enforcing strict separation between the data, business logic (manager), and presentation layers. All state is managed through the **Bloc/Cubit** pattern, and the entire dependency graph is resolved at startup via **GetIt** service locator, ensuring testability, scalability, and maintainability across all modules.

---

## Technology Stack

| Category                 | Technology                                                  |
| :----------------------- | :---------------------------------------------------------- |
| **Framework**            | Flutter (Dart SDK ^3.11.1)                                  |
| **Backend**              | Supabase (Authentication, PostgreSQL Database, Storage)     |
| **State Management**     | flutter_bloc / Cubit + Equatable                            |
| **Dependency Injection** | GetIt (Service Locator)                                     |
| **Architecture**         | Clean Architecture (data / manager / presentation)          |
| **Local Storage**        | SharedPreferences, Flutter Secure Storage                   |
| **Networking**           | Supabase Client SDK, HTTP                                   |
| **Maps and Geolocation** | flutter_map, latlong2, Geolocator, Geocoding                |
| **Notifications**        | flutter_local_notifications                                 |
| **UI and Animation**     | Lottie, Confetti, Shimmer, Skeletonizer, Thanos Snap Effect |
| **Authentication**       | Supabase Auth, Google Sign-In                               |
| **Offline Support**      | flutter_offline, connectivity_plus                          |
| **Environment Config**   | flutter_dotenv (.env)                                       |
| **PDF Rendering**        | flutter_cached_pdfview                                      |
| **Typography**           | Poppins (100-900 weights), BrunoAceSC                       |

---

## Module A -- Job Seeker (Talent) Application

### Overview

The Job Seeker module delivers a gamified, engagement-driven experience designed to maximize profile visibility and user retention. Seekers build rich, structured profiles and are rewarded through a points-based system that incentivizes daily activity, profile completeness, and platform interaction.

### Key Features

- **Gamification Engine** -- A comprehensive points and rewards system powered by a dedicated `PointsCubit` and `PointsRepo`. Users accumulate points through daily check-ins, profile completion milestones, and engagement actions. Visual reward feedback is delivered via confetti animations and Lottie sequences, accompanied by audio cues.

- **Smart Profiles** -- Rich, data-dense user profiles with support for avatar upload and full-screen preview, embedded CV/PDF viewing, contact information with phone field validation, social media links, and an interactive map displaying the seeker's location via geolocation services.

- **Offline Mode** -- A global `OfflineBuilder` overlay integrated at the application root intercepts connectivity state via `connectivity_plus`. When the device loses connection, a full-screen offline notification is presented while preserving the underlying screen state. Session restoration and data fallback to `SharedPreferences` ensure resilience during network disruption.

- **Local Notifications** -- Scheduled daily check-in reminders and profile view notifications are managed through `LocalNotificationService`, registered as a lazy singleton in the dependency graph and initialized at application startup.

- **Profile Views Tracking** -- A dedicated `ProfileViewsCubit` tracks and displays who has viewed the seeker's profile, driving engagement through social proof.

- **Company Discovery** -- Seekers can browse and view detailed company profiles through the `company_view` feature, enabling informed job-seeking decisions.

- **Settings and Account Management** -- A comprehensive settings interface provides account controls, feedback submission, and access to the About Us section.

### Walkthrough


https://github.com/user-attachments/assets/3fd65718-e701-41b6-9e45-d6bd2263997d


### Directory Structure

The following tree represents the exact Clean Architecture layout of the Job Seeker module as it exists in the codebase. Each feature enforces the `data / manager / presentation` separation where applicable.

```
lib/features/users/
|
|-- home/
|   |-- data/
|   |   |-- models/
|   |   |-- repos/
|   |       |-- user_home_repo.dart
|   |       |-- user_home_repo_impl.dart
|   |-- manager/
|   |   |-- user_home_cubit.dart
|   |   |-- user_home_state.dart
|   |-- presentation/
|       |-- components/
|       |   |-- cv_section.dart
|       |   |-- home_info_row.dart
|       |   |-- social_media_row.dart
|       |-- screens/
|       |   |-- user_home_screen.dart
|       |-- widgets/
|           |-- build_badge_widget.dart
|           |-- build_contact_icon_button.dart
|           |-- curve_painter.dart
|           |-- full_screen_avatar_dialog.dart
|           |-- home_total_points_container.dart
|           |-- location_map_section.dart
|           |-- profile_header_delegate.dart
|
|-- user_info/
|   |-- data/
|   |   |-- models/
|   |   |-- repos/
|   |       |-- user_info_repo.dart
|   |       |-- user_info_repo_impl.dart
|   |-- manager/
|   |   |-- user_info_cubit.dart
|   |-- presentation/
|       |-- screens/
|       |-- widgets/
|
|-- edit_profile/
|   |-- data/
|   |   |-- models/
|   |   |-- repos/
|   |-- manager/
|   |   |-- edit_profile_cubit.dart
|   |-- presentation/
|       |-- screens/
|           |-- edit_profile_screen.dart
|
|-- points/
|   |-- data/
|   |   |-- models/
|   |   |-- repos/
|   |       |-- points_repo.dart
|   |       |-- points_repo_impl.dart
|   |-- manager/
|   |   |-- points_cubit.dart
|   |   |-- points_state.dart
|   |-- presentation/
|       |-- screens/
|       |-- widgets/
|
|-- profile_views/
|   |-- data/
|   |   |-- models/
|   |   |-- repos/
|   |-- manager/
|   |   |-- profile_views_cubit.dart
|   |-- presentation/
|       |-- screens/
|       |-- widgets/
|
|-- notification/
|   |-- data/
|   |   |-- services/
|   |       |-- local_notification_service.dart
|   |   |-- other/
|
|-- company_view/
|   |-- data/
|   |-- presentation/
|       |-- screens/
|           |-- company_view_screen.dart
|       |-- widgets/
|
|-- settings_users/
|   |-- screens/
|   |-- widgets/
|
|-- root/
    |-- screens/
        |-- user_root_screen.dart
    |-- widgets/
```

---

## Module B -- Company (Employer) Application

### Overview

The Company module provides employers with a powerful talent discovery and pipeline management interface. Employers register their organization through a structured onboarding flow, then gain access to a searchable, filterable talent pool backed by Supabase and locally cached preferences for performance optimization.

### Key Features

- **Rich Candidate Discovery** -- The employer home screen (`CompanyHomeCubit` / `CompanyHomeRepo`) presents a searchable feed of job seeker profiles. An advanced filter bottom sheet allows employers to narrow candidates by multiple criteria. Search and filter state is managed entirely through Cubit, ensuring reactive and predictable UI behavior.

- **Talent Pipeline and Candidate Cards** -- Each candidate is rendered as a detailed `SeekerCard` with a preview overlay (`SeekerPreviewOverlay`) that enables quick candidate evaluation without full navigation. Action filter buttons and preview chip widgets provide contextual controls directly within the feed.

- **Saved Profiles** -- Employers can save and shortlist candidates through the dedicated `saved` feature. Saved profiles are persisted and accessible from the company root navigation, enabling structured pipeline management.

- **Talent Detail View** -- A comprehensive `TalentDetailsScreen` provides employers with a full-profile deep dive into any candidate, displaying all seeker information including skills, experience, CV, location, and contact details.

- **Company Profile Management** -- Employers maintain their organization's profile through `CompanyInfoScreen` (initial setup with `CompanyInfoCubit`) and `CompanyProfileScreen` (ongoing management), ensuring accurate representation to job seekers.

- **Structured Onboarding** -- Company registration follows a dedicated `company_info` flow with its own `data / manager / presentation` layers, collecting organizational details and persisting completion state across both Supabase and `SharedPreferences` for reliable session restoration.

### Walkthrough


https://github.com/user-attachments/assets/6da4b6c3-bbdb-481c-a95b-5781fc551fa5


### Directory Structure

The following tree represents the exact Clean Architecture layout of the Company module as it exists in the codebase.

```
lib/features/company/
|
|-- home/
|   |-- data/
|   |   |-- models/
|   |   |-- repos/
|   |       |-- company_home_repo.dart
|   |       |-- company_home_repo_impl.dart
|   |-- manager/
|   |   |-- company_home_cubit.dart
|   |   |-- company_home_state.dart
|   |-- presentation/
|       |-- components/
|       |   |-- bottom_section_company_home.dart
|       |   |-- filter_bottom_sheet.dart
|       |   |-- fixed_header_company_home.dart
|       |   |-- seeker_card.dart
|       |-- screens/
|       |   |-- company_home_screen.dart
|       |-- widgets/
|           |-- action_filtter_buttons.dart
|           |-- preview_chip_widget.dart
|           |-- search_filter_bar.dart
|           |-- seeker_preview_overlay.dart
|
|-- company_info/
|   |-- data/
|   |   |-- models/
|   |   |-- repos/
|   |       |-- company_info_repo.dart
|   |       |-- company_info_repo_impl.dart
|   |-- manager/
|   |   |-- company_info_cubit.dart
|   |-- presentation/
|       |-- screens/
|           |-- company_info_screen.dart
|
|-- saved/
|   |-- screens/
|   |   |-- saved_screen.dart
|   |-- widgets/
|
|-- user_details/
|   |-- screens/
|   |   |-- talent_details_screen.dart
|   |-- widgets/
|
|-- profile_company/
|   |-- screens/
|   |   |-- company_profile_screen.dart
|   |-- widgets/
|
|-- root/
    |-- screens/
        |-- company_root_screen.dart
    |-- widgets/
```

---

## Architecture Overview

JOBY adheres to a strict **Clean Architecture** pattern, adapted to Flutter conventions. The architecture enforces unidirectional data flow and clear separation of concerns across three layers.

### Layer Definitions

| Layer            | Responsibility                                                                                                                                                                                                                            |
| :--------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **data**         | Contains repository interfaces, repository implementations, and data models. Encapsulates all data access logic, including Supabase queries, local storage reads, and model serialization/deserialization.                                |
| **manager**      | Houses the Cubit classes and their corresponding state definitions. This layer orchestrates business logic by consuming repository abstractions and emitting discrete, typed states to the presentation layer.                            |
| **presentation** | Comprises screens, widgets, and components. Screens observe Cubit state via `BlocProvider` / `BlocBuilder` and render the UI accordingly. Components encapsulate complex, reusable visual sections; widgets represent atomic UI elements. |

### Dependency Injection

All dependencies are resolved through **GetIt**, configured in a single centralized registration file at `lib/core/di/dependency_injection.dart`. The initialization function `initGetIt()` is invoked during application startup in `main.dart`, prior to `runApp`.

The registration strategy follows a deliberate pattern:

- **Repositories** are registered as `LazySingleton` instances, ensuring a single shared instance per data source across the application lifecycle.
- **Cubits** are registered as `Factory` instances, creating a fresh Cubit for each screen or `BlocProvider` to prevent state leakage between navigations.
- **Core services** (SupabaseClient, SharedPreferences, AudioPlayer, LocalNotificationService) are registered as `LazySingleton` instances.

### State Management

State management is implemented exclusively through **Cubit** (a lightweight variant of Bloc). Each feature that requires state management defines:

1. A **Cubit** class that extends `Cubit<State>` and accepts the corresponding repository via constructor injection.
2. A **State** class (or sealed class hierarchy) that extends `Equatable` for value-based equality comparison.

Cubits are provided to the widget tree via `BlocProvider` (or `MultiBlocProvider` for composite screens) at the route level, as configured in `AppRouter.generateRoute()`. This ensures that state lifecycle is tied to route lifecycle.

### Routing

Navigation is managed through a centralized `AppRouter` class using Flutter's `onGenerateRoute` mechanism. All route names are defined as static constants in the `Routes` class. The router handles deep link interception for Supabase email verification callbacks and provides Cubit injection at the route level via `BlocProvider`.

### Shared Module

Features common to both user types reside in `lib/features/common/`, including:

| Feature             | Description                                          |
| :------------------ | :--------------------------------------------------- |
| **auth**            | Authentication (login, registration, Google Sign-In) |
| **on_boarding**     | User type selection and initial onboarding flow      |
| **forgot_password** | Password recovery via Supabase email verification    |
| **feed_back**       | In-app feedback and advice submission                |
| **about_us**        | Static informational screens                         |
| **settings**        | Shared settings interface                            |

### Error Handling

A centralized `ErrorHandler` utility class provides human-readable error message translation for all Supabase exception types (`AuthException`, `PostgrestException`, `StorageException`) as well as network-level exceptions (`SocketException`, `TimeoutException`). Repositories consume this handler to surface consistent error messages to the Cubit layer via `Either` (from the `dartz` package) for functional error propagation.

---

## Installation and Setup

### Prerequisites

- Flutter SDK (Dart ^3.11.1)
- A configured Supabase project (with Authentication, Database, and Storage enabled)
- Android Studio or Xcode (for platform-specific builds)

### Steps

**1. Clone the repository.**

```bash
git clone https://github.com/Ismail-Magdy/joby.git
cd joby
```

**2. Create the environment configuration file.**

Create a `.env` file in the project root with the following variables:

```
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

**3. Install dependencies.**

```bash
flutter pub get
```

**4. Run the application.**

```bash
flutter run
```

**5. Build for production (optional).**

```bash
flutter build apk --release
flutter build ios --release
```

---

> **Maintained by Ismail Magdy**
> [GitHub](https://github.com/Ismail-Magdy) -- [LinkedIn](https://www.linkedin.com/in/ismailmagdy021) -- [Behance](https://www.behance.net/ismailmagdy4)
