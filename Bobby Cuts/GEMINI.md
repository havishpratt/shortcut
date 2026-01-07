# Project Context: Bobby Cuts

## Overview
This is an iOS application built with **SwiftUI** for a barber shop booking system. The project directory is named "Bobby Cuts", but the current codebase refers to the business as "Ryan's Cuts".

## Architecture
The project follows the **MVVM (Model-View-ViewModel)** pattern, although currently, the implementation is monolithic.

### Directory Structure
*   `ContentView.swift`: **Crucial File.** Currently contains the **entire application logic**, including:
    *   **App Entry Point:** `RyansCutsApp` struct.
    *   **Models:** `Booking` and `TimeSlot` structs.
    *   **ViewModel:** `BookingViewModel` class managing business logic (dates, slots, booking simulation).
    *   **Views:** `HomeView`, `DateSelectionView`, `TimeSlotView`, `BookingFormView`, `BookingConfirmationView`, and helper views.
*   `Booking.swift`: Currently empty/unused (likely a leftover or placeholder).
*   `Models/`: **Empty**. Intended destination for data models.
*   `ViewModels/`: **Empty**. Intended destination for `BookingViewModel`.
*   `Assets.xcassets`: Contains app assets (AppIcon, AccentColor).

## Key Components (in `ContentView.swift`)

### Business Logic (`BookingViewModel`)
*   Manages booking slots for Tuesday-Saturday (9am-5pm).
*   `getAvailableDates()`: Returns valid booking dates for the next 14 days.
*   `getAvailableSlots(for:)`: Generates hourly slots, filtering out past times and already booked slots.
*   `bookSlot(...)`: Simulates a booking transaction and updates the local state.

### UI Flow
1.  **HomeView:** Landing page showing either date selection or a confirmation.
2.  **DateSelectionView:** Lists available dates.
3.  **TimeSlotView:** Grid of available hours for a selected date.
4.  **BookingFormView:** Collects user details (Name, Phone, Email) and payment method.
5.  **BookingConfirmationView:** Displays success message and booking details.

## Development Status
*   **Prototype Stage:** The app is functional but needs refactoring.
*   **Refactoring Needed:** The code in `ContentView.swift` should be modularized by moving structs and classes into their respective directories (`Models/`, `ViewModels/`) and splitting views into separate files.
*   **Naming Inconsistency:** The project folder suggests "Bobby Cuts", while the UI displays "Ryan's Cuts". This should be unified.

## Building and Running
*   Open the project in **Xcode**.
*   Select the target scheme (likely implicit or `Bobby Cuts`).
*   Run on a Simulator or Device (`Cmd + R`).
*   **Prerequisites:** macOS with Xcode installed.
