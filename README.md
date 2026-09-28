# Habit Tracker

A simple Flutter habit tracker app: add habits, check them off daily, see your streak, and everything persists on-device.

## What's included

```
lib/
  main.dart                 # app entry point
  models/habit.dart         # Habit data model + streak calculation
  services/habit_storage.dart  # save/load habits via shared_preferences
  screens/home_screen.dart  # main screen (list, add, toggle, delete)
  widgets/habit_tile.dart   # single habit row UI
pubspec.yaml                 # dependencies
```

This zip only has the `lib/` code + `pubspec.yaml` — it does **not** include the
`android/`, `ios/`, `web/` platform folders, since those are auto-generated.

## First-time setup (do this once)

1. Install the Flutter SDK: https://docs.flutter.dev/get-started/install
2. Confirm it works:
   ```
   flutter doctor
   ```

## Getting this project running

1. Create a fresh Flutter project (this generates the platform folders):
   ```
   flutter create habit_tracker
   cd habit_tracker
   ```
2. Delete the generated `lib/main.dart` and `pubspec.yaml`, then copy in the files
   from this zip (`lib/`, `pubspec.yaml`, `.gitignore`, `README.md`) into the new
   project folder, replacing what's there.
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run it (with an emulator running or a device plugged in):
   ```
   flutter run
   ```

## Pushing to GitHub

From inside the `habit_tracker` project folder:

```
git init
git add .
git commit -m "Initial commit: habit tracker app"
git branch -M main
git remote add origin https://github.com/<your-username>/<your-repo>.git
git push -u origin main
```

## How it works (quick tour)

- **Habit model** (`models/habit.dart`): each habit has a name and a list of
  completed dates (as strings). `currentStreak` walks backward from today
  counting consecutive completed days.
- **Storage** (`services/habit_storage.dart`): habits are serialized to JSON
  and saved with `shared_preferences`, so they're still there after you close
  the app.
- **Home screen** (`screens/home_screen.dart`): loads habits on start, and
  saves after every add/toggle/delete.
- **State management**: this uses plain `setState` — no Provider/Riverpod/Bloc.
  Good enough for a project this size, and easier to learn from.

## Ideas to extend it

- Calendar view showing which days were completed
- Reminders/notifications
- Categories or colors per habit
- Weekly/monthly completion percentage
- Swap `setState` for `Provider` once you're comfortable with the basics
