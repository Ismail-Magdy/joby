# 🚀 Joby - Modern Job Seeking Platform

Joby is a comprehensive mobile application built with Flutter, designed to seamlessly connect **Job Seekers** with **Companies**. It provides an intuitive, high-performance, and scalable platform for professionals to build their profiles, interact with an AI Career Coach, and apply for jobs.

---

## 🏗️ Architecture & Tech Stack

This project strictly follows **Clean Architecture** principles to ensure scalability, maintainability, and separation of concerns. The codebase is divided into feature-based layers: `presentation` (UI), `manager` (State Management), and `data` (Repositories & Models).

### Core Technologies:

- **Framework:** Flutter (Dart)
- **State Management:** Flutter Bloc (Cubit)
- **Backend as a Service (BaaS):** Supabase
  - Authentication
  - PostgreSQL Database
  - Storage (PDF Resumes)
  - Edge Functions / Database Webhooks
- **Dependency Injection:** `get_it`
- **AI Integration:** Google Gemini API (`gemini-1.5-pro` model)
- **Routing:** Centralized `AppRouter` with `MaterialPageRoute`

### Key Packages:

- `flutter_bloc` & `get_it` (State & DI)
- `supabase_flutter` (Backend connectivity)
- `google_generative_ai` (Joby AI Assistant)
- `dio` & `path_provider` & `open_filex` (CV Downloading logic)
- `file_picker` (CV Uploading)
- `url_launcher` (Social & WhatsApp deep-linking)
- `flutter_screenutil` (Responsive UI)
- `ionicons` (Icons)

---

## ✨ Current Features (Job Seeker Flow)

### 1. 🔐 Role-Based Routing

- Dynamic splash routing checking Supabase session state.
- Redirects to either `CompanyHomeScreen` or `UserRootScreen` based on the authenticated `userType`.
- Forces incomplete profiles to the `UserInfoScreen` before accessing the main app.

### 2. 📱 User Root Navigation

- Utilizes an `IndexedStack` for bottom navigation (Profile, AI Chat, Settings) to preserve the state of local Cubits without cluttering the global provider tree.

### 3. 👤 Profile & CV Management

- **Glassmorphism UI:** Highly customized header using `CustomPainter`.
- **Social Links:** Direct deep links to WhatsApp (with Egyptian '+20' format handler), LinkedIn, and GitHub.
- **CV Downloader:** Downloads the user's PDF resume directly from Supabase Storage to the device's temporary directory and triggers the OS native "Open With" dialog.
- **Edit Profile:** Seamlessly updates user info and uploads new PDF resumes to the Supabase `resumes` bucket.

### 4. 🤖 Joby AI Assistant

- An integrated AI career coach powered by Google Gemini.
- Maintains chat history within the `IndexedStack` so contextual conversations are preserved while navigating between tabs.

### 5. 📬 Real-time Feedback System (Telegram Integration)

- A dedicated "Send Feedback" feature that completely bypasses default email clients (`mailto:` constraints).
- Saves feedback directly to a Supabase `feedback` table.
- **Automated Notifications:** Utilizes Supabase's `pg_net` extension and PostgreSQL Triggers to instantly forward user feedback directly to a Telegram Bot.

### 6. 🌐 Global Offline Mode

- Monitors internet connectivity continuously in the background using `flutter_offline`.
- Displays a non-intrusive, seamless full-screen "You're Offline" overlay instantly across the entire application whenever connectivity drops.

### 7. ⚙️ Advanced UX & Profile Management

- **Shimmer Loaders:** Replaces generic circular loading indicators with custom `ShimmerBox` placeholders that exactly mirror the UI layout (e.g., Profile header, badges, CV cards) for a premium, non-blocking feeling.
- **Smart Editing:** Users can edit Name, Level, Job Title, Work Types, and direct links without losing any pre-existing text. Unchanged fields are perfectly preserved.
- **Image Avatars:** Allows dynamic profile picture uploading using device gallery, saved securely to Supabase `avatars` bucket.
- **Unsaved Changes Guard:** Prevents accidental data loss by prompting users with a custom unified intercept dialog when hitting 'Back' with pending UI edits.
- **Polished Logout Flow:** Uses an explicit `AlertDialog` intercept before signing out to prevent accidental session termination.

---

## 📸 Screenshots

*(To add screenshots to your GitHub repository: Create a `docs/screenshots` folder inside this project, place your `.png` or `.jpg` files there, and then update this section using the markdown format: `![Description](docs/screenshots/image_name.png)`)*

| Login Screen | Home (Profile) | AI Chat |
| :---: | :---: | :---: |
| *(Image 1)* | *(Image 2)* | *(Image 3)* |
| **Settings** | **Edit Profile** | **Offline Mode** |
| *(Image 4)* | *(Image 5)* | *(Image 6)* |

---

## 🛠️ Developer Guidelines

If you are contributing to this project, please adhere to the following rules:

1.  **Strict Separation:** Never put business logic inside the UI. Always use Cubits and Repositories.
2.  **Error Handling:** Repositories must return `Either<Failure, Type>` (or handle `try-catch` cleanly), and Cubits must emit specific Error states to be handled by `ScaffoldMessenger` in the UI.
3.  **UI Consistency:** Do not use hardcoded `SizedBox`. Utilize the custom `verticalSpace()` and `horizontalSpace()` helpers.
4.  **Local State:** Provide Cubits locally using `BlocProvider` exactly where they are needed (e.g., inside the `IndexedStack` tabs) to avoid global state bloat.

---

## 🚀 Getting Started

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/Ismail-Magdy/joby.git](https://github.com/Ismail-Magdy/joby.git)
   ```
