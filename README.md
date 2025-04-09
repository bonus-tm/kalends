# Kalends

A macOS application for marking days on a calendar. Vibe coded in Cursor.

## Features

- Display of months in rows with days as squares
- Ability to toggle marking of any day with a simple click
- Visual indicators for today's date (red border)
- Year navigation

## Requirements

- macOS 13.0+ (Ventura or newer)
- Xcode 14.0+
- Swift 5.5+

## Building the App

### Using Xcode

1. Open the `Kalends.xcodeproj` file in Xcode
2. Select the "Kalends" scheme and your target macOS device
3. Click the Run button or press Cmd+R to build and run the app

## Usage

- Click on any day square to toggle its marked state (pink background)
- Use the year navigation buttons at the bottom to change the displayed year
- The current day is highlighted with a red border

## Structure

- `KalendsApp.swift` - The main app entry point
- `ContentView.swift` - The main view containing the calendar
- `MonthRowView.swift` - View for displaying a single month row
- `DaySquareView.swift` - View for individual day squares

## License

This project is available under the MIT license. 