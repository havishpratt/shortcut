# Barber Cuts ✂️

A mobile booking app for college students to schedule affordable haircuts. Built with SwiftUI and Supabase.

## Features

- **Easy Booking**: Browse available dates and time slots, book in seconds
- **Google & Apple Sign-In**: Quick authentication with social providers
- **Auto-fill Forms**: User info is saved and pre-populated for future bookings
- **Real-time Availability**: Slots update based on existing bookings
- **Dark Theme UI**: Modern, clean interface optimized for mobile

## Tech Stack

- **Frontend**: SwiftUI (iOS 15.6+)
- **Backend**: Supabase (PostgreSQL + Auth + Realtime)
- **Authentication**: Sign in with Apple, Google OAuth

## Project Structure

```
Bobby Cuts/
├── RyansCutsApp.swift       # App entry point, handles OAuth callbacks
├── ContentView.swift        # Root view, switches between onboarding/main app
├── AppConfig.swift          # Supabase configuration
│
├── Models/
│   ├── Booking.swift        # Booking data model
│   ├── TimeSlot.swift       # Time slot representation
│   ├── BarberSettings.swift # Shop settings model
│   └── DailySchedule.swift  # Schedule model
│
├── ViewModels/
│   ├── BookingViewModel.swift  # Booking logic, slot availability
│   └── AuthViewModel.swift     # Authentication state, user data
│
├── Views/
│   ├── Theme.swift             # App-wide colors, styles, components
│   ├── HomeView.swift          # Main screen with header
│   ├── DateSelectionView.swift # Date picker cards
│   ├── TimeSlotView.swift      # Available time slots grid
│   ├── BookingFormView.swift   # Customer info form
│   ├── BookingConfirmationView.swift # Success screen
│   ├── OnboardingView.swift    # Sign-in flow
│   └── ContactRyanButton.swift # Contact action button
│
├── Services/
│   └── BookingService.swift    # Supabase API calls
│
└── backend/
    ├── schema.sql              # Database schema
    └── supabase/               # Supabase edge functions
```

## Setup

### Prerequisites

- Xcode 14+
- iOS 15.6+ device or simulator
- Supabase account

### 1. Clone the Repository

```bash
git clone <repository-url>
cd "Bobby Cuts"
```

### 2. Configure Supabase

1. Create a new Supabase project at [supabase.com](https://supabase.com)

2. Run the database schema:
   - Go to SQL Editor in Supabase Dashboard
   - Copy contents of `backend/schema.sql`
   - Execute the SQL

3. Update `AppConfig.swift` with your Supabase credentials:
   ```swift
   let supabase = SupabaseClient(
       supabaseURL: URL(string: "YOUR_SUPABASE_URL")!,
       supabaseKey: "YOUR_SUPABASE_ANON_KEY"
   )
   ```

### 3. Configure Authentication

#### Google Sign-In

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create OAuth 2.0 credentials (iOS type)
3. Add your Bundle ID
4. In Supabase Dashboard → Authentication → Providers → Google:
   - Enable Google provider
   - Add Client ID and Client Secret
5. Add URL scheme to Info.plist:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>com.yourapp.bundleid</string>
           </array>
       </dict>
   </array>
   ```

#### Apple Sign-In

1. In Xcode: Signing & Capabilities → Add "Sign in with Apple"
2. In [Apple Developer Portal](https://developer.apple.com):
   - Create a Services ID
   - Create a Key with "Sign in with Apple" enabled
3. In Supabase Dashboard → Authentication → Providers → Apple:
   - Enable Apple provider
   - Add Services ID, Team ID, Key ID, and Private Key

### 4. Build and Run

1. Open `Bobby Cuts.xcodeproj` in Xcode
2. Select your target device/simulator
3. Build and run (⌘R)

## Database Schema

### Tables

- **bookings**: Customer appointments
  - `id`, `date`, `customer_name`, `customer_phone`, `customer_email`, `status`
  
- **barber_settings**: Global configuration
  - `max_cuts_per_day`, `slot_duration_minutes`, `auto_approve`
  
- **weekly_schedule**: Recurring availability
  - `day_of_week`, `start_hour`, `end_hour`, `is_active`
  
- **schedule_overrides**: Date-specific blocks/custom hours

### Booking Status

- `pending` - Awaiting confirmation
- `confirmed` - Approved by barber
- `denied` - Rejected

## Configuration

### Business Hours

Edit in `BookingViewModel.swift`:
```swift
let businessDays: Set<Int> = [1, 2, 3, 4, 5, 6, 7] // 1=Sun, 7=Sat
let businessHours = Array(16...19) // 4pm-7pm (24hr format)
let bookingWindowDays = 14 // How far ahead users can book
```

### Timezone

The app uses America/New_York timezone for all scheduling. Update in `BookingViewModel.swift` if needed:
```swift
if let timeZone = TimeZone(identifier: "America/New_York") {
    cal.timeZone = timeZone
}
```

### Theming

Colors and styles are defined in `Views/Theme.swift`:
- `AppTheme.accent` - Primary accent color
- `AppTheme.backgroundPrimary` - Main background
- `AppTheme.textPrimary` - Primary text color

## Usage Flow

1. **Onboarding**
   - User signs in with Google or Apple
   - Confirms/edits name and email
   - Enters phone number

2. **Booking**
   - Browse available dates on home screen
   - Select a date to see time slots
   - Tap a time slot to book
   - Form auto-fills with saved user info
   - Confirm booking

3. **Confirmation**
   - User sees success screen
   - Booking is saved as "pending"
   - User receives email when confirmed

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is private and proprietary.

## Contact

For questions or support, use the in-app "Contact Us" button or reach out directly.
