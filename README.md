# TaskLister

TaskLister is a lightweight SwiftUI-powered iOS application that helps you capture tasks, organize them by urgency, and stay focused throughout the day. The repository ships with pure Swift source files and asset metadata so everything stays reviewable in plain text—no opaque Xcode project bundle required.

## Features

- ✅ **Quick capture** – Add new tasks with notes, optional due dates, and priority in a single form.
- 📆 **Smart filtering** – Toggle between *All*, *Today*, *Upcoming*, and *Done* views to focus on what matters now.
- 🔍 **Search** – Instantly find tasks by title or notes.
- ✏️ **Inline editing** – Tap any row to update it, or swipe to complete and delete.
- ☁️ **Persistent storage** – Tasks are saved locally as JSON so your list survives relaunches.
- 🎨 **Custom design assets** – Includes simple accent color and a vector-based app icon that stays reviewable in plain text.

## Project structure

```
TaskLister/
├── Models/                  # Data models (Task, TaskPriority)
├── Stores/                  # ObservableObject store with persistence
├── Views/                   # SwiftUI screens and reusable components
├── Utilities/               # Shared helpers (date formatting)
├── Assets.xcassets/         # App icon + accent color definitions
├── Preview Content/         # Preview assets for SwiftUI previews
├── Info.plist               # Suggested app configuration values
└── TaskListerApp.swift      # Main entry point wiring the views together
```

## Getting started in Xcode

Because there is no `.xcodeproj` checked in, you can decide whether to embed the sources into an existing project or spin up a brand-new one. Here is a quick path to a fresh SwiftUI app:

1. Open Xcode 15 (or newer) and create a new **App** project targeting iOS. Name it **TaskLister** (or anything you prefer).
2. When the project opens, delete the boilerplate `ContentView.swift` and `YourAppNameApp.swift` files Xcode generated.
3. Drag the entire `TaskLister` folder from this repository into the Project Navigator, making sure "Copy items if needed" is checked and the main app target is selected.
4. If you want the sample accent color and SVG app icon metadata, also drag `TaskLister/Assets.xcassets` into your project's asset catalog.
5. Build and run (⌘R). The SwiftUI hierarchy defined in `TaskListerApp.swift` will become the app's entry point automatically.

> **Note:** The project targets iOS 16.0 and up because it relies on `NavigationStack` and other modern SwiftUI APIs.

## Customization ideas

- Hook the `TaskStore` up to CloudKit or Core Data for multi-device sync.
- Extend the `Task` model with reminders using `UserNotifications`.
- Add widgets or lock-screen complications that surface due-today tasks.
- Group tasks into projects with color-coded sections.

Feel free to tweak the UI and logic to fit your personal workflow—this repo is a solid foundation to build on.
