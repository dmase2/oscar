# Oscars Winners App Specification

## Overview
A simple Flutter application to browse Oscar-winning movies, with no login required. The app uses a local ObjectBox database populated from a CSV file and provides a visually rich experience with movie posters and decade-based navigation.

## Features
- **No Authentication:**
  - The app is accessible to all users without any login or registration.

- **Data Source:**
  - Use a oscar_winner.csvfile to download and populate an ObjectBox database containing all Oscar winners.

- **State Management:**
  - Use Riverpod for managing application state.

- **Framework:**
  - Build the application using Flutter.

- **Movie Posters:**
  - Download movie posters for each movie and store the poster links in the database.

- **UI/UX:**
  
  - Allow users to scroll by decade to browse different sets of movies.

## Technical Requirements
- **Flutter** for cross-platform mobile development.
- **ObjectBox** for local database storage.
- **Riverpod** for state management.
- **CSV Parsing** to import Oscar winners data.
- **Poster Downloading** via an API or web scraping, with poster URLs stored in the database.
- **Responsive UI** to support scrolling and decade navigation.

## Future Enhancements (Optional)
- Add search and filter functionality.
- Support for additional movie details or categories.
- Offline support for all data and images.
