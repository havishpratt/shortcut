# TODO

## High Priority

- [ ] **Use DB-driven schedule** — `BookingService` fetches `weekly_schedule` and `barber_settings` from Supabase, but `BookingViewModel` ignores them and uses hardcoded `businessDays`/`businessHours`/`bookingWindowDays`. Wire the fetched data into slot generation so the barber can change hours without a code update.

- [ ] **Fix auth session persistence** — Auth state is saved to `UserDefaults` as a simple boolean. On relaunch, there's no validation that the Supabase session is still valid. A user could be "authenticated" with an expired/revoked session.

## Features

- [ ] **Booking history / cancel flow** — Users can book but have no way to view past bookings or cancel an upcoming one. The `bookings` table already supports status tracking.

- [ ] **Admin panel for barber** — No UI exists for the barber to confirm/deny pending bookings or adjust `barber_settings`/`weekly_schedule`. The DB schema and RLS policies are already set up for admin access.

- [ ] **Schedule overrides** — The README references a `schedule_overrides` table for date-specific blocks/custom hours, but it doesn't exist in `schema.sql` and there's no app support for it.

- [ ] **Push notifications** — No notification system for booking confirmations or reminders. Users are told they'll "receive email when confirmed" but nothing implements that.

## Cleanup

- [ ] **Clean up legacy naming** — Several references to the old name remain: `RyansCutsApp`, `ContactRyanButton`, doc comment "Fetches Ryan's weekly schedule" in BookingService.

- [ ] **Move credentials out of source** — `AppConfig.swift` has hardcoded Supabase URL and anon key. Consider using an `.xcconfig` file or environment-based config.
