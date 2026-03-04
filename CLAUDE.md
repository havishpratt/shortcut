# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Barber Cuts** (source folder still named "Bobby Cuts") — an iOS booking app for college students to schedule affordable haircuts. Built with SwiftUI + Supabase.

## Build & Run

- Open `Bobby Cuts.xcodeproj` in Xcode
- Select a target device/simulator and press **⌘R**
- No Makefile, Podfile, or Package.swift — dependencies are managed via Xcode's Swift Package Manager integration
- There are no automated tests at this time

## Architecture

**MVVM with SwiftUI.** State flows from two shared `ObservableObject` ViewModels injected at the app root via `@EnvironmentObject`:

- `AuthViewModel` — authentication state, onboarding steps, user profile (name/email/phone), UserDefaults persistence
- `BookingViewModel` — availability logic, 14-day preload of bookings, Supabase Realtime subscription for live slot updates

`RyansCutsApp.swift` is the `@main` entry point. It injects both ViewModels and handles Google OAuth URL callbacks. `ContentView.swift` switches between `OnboardingView` and `HomeView` based on auth state.

**Data layer** lives in `Services/BookingService.swift`, which wraps all Supabase calls (fetch, submit, realtime subscribe). ViewModels call into the service and never access Supabase directly except for auth.

**Supabase client** is a global singleton in `AppConfig.swift`.

## Key Patterns

- **Timezone:** All scheduling is forced to `America/New_York`. Every `Calendar` instance used for date math must set this timezone explicitly.
- **Optimistic UI:** `BookingViewModel` updates local state immediately before server confirmation, then reloads on the Realtime callback.
- **Onboarding steps:** Three-step flow (sign-in → confirm profile → phone number) managed by a step enum in `AuthViewModel`.
- **Theme:** All colors, button styles, and card modifiers are defined in `Views/Theme.swift`. Use `AppTheme.*` constants and `AccentButtonStyle`/`SecondaryButtonStyle` for consistency.

## Business Logic Configuration

Configured in `BookingViewModel.swift`:
```swift
let businessDays: Set<Int> = [1, 2, 3, 4, 5, 6, 7] // 1=Sun, 7=Sat
let businessHours = Array(16...19)                   // 4pm–7pm
let bookingWindowDays = 14
```

## Database

Schema is in `Bobby Cuts/backend/schema.sql`. Four tables: `bookings`, `barber_settings`, `weekly_schedule`, `profiles`. Booking statuses: `pending`, `confirmed`, `denied`. RLS policies allow public insert/read on bookings; admin-only writes for settings.

## Authentication

- **Apple Sign-In:** Uses `AuthenticationServices` → `AuthViewModel` → Supabase
- **Google OAuth:** Custom URL scheme (`com.prattipati.barbercuts://google-callback`) registered in `Bobby-Cuts-Info.plist`; callback handled in `RyansCutsApp.swift`
