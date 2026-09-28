\# Habit Tracker



A simple habit tracker app built with Flutter. Add habits, check them off each day, and watch your streaks grow. Everything is saved on your device, so your habits are still there when you reopen the app.



\## Features



\- Add and delete habits

\- Mark a habit as done for today

\- Automatic streak counter

\- Local storage with `shared\_preferences`



\## Project structure



```

lib/

&#x20; main.dart                    # app entry point

&#x20; models/habit.dart            # Habit model + streak calculation

&#x20; services/habit\_storage.dart  # save/load habits

&#x20; screens/home\_screen.dart     # main screen

&#x20; widgets/habit\_tile.dart      # single habit row

```



\## Run it locally



1\. Install Flutter: https://docs.flutter.dev/get-started/install

2\. Clone this repo and open the folder

3\. Install dependencies:

```

&#x20;  flutter pub get

```

4\. Run the app:

```

&#x20;  flutter run

```



\## Ideas for the future



\- Calendar view of completed days

\- Daily reminders

\- Colors and icons for each habit

\- Weekly completion percentage

