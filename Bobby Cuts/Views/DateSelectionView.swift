import SwiftUI

struct DateSelectionView: View {
    @EnvironmentObject var viewModel: BookingViewModel
    @State private var appeared = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section Header
            VStack(alignment: .leading, spacing: 6) {
                Text("Pick a Date")
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Choose your preferred day")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(Array(viewModel.getAvailableDates().enumerated()), id: \.element) { index, date in
                        DateCard(date: date)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.7)
                                .delay(Double(index) * 0.05),
                                value: appeared
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            appeared = true
        }
    }
}

struct DateCard: View {
    @EnvironmentObject var viewModel: BookingViewModel
    let date: Date
    
    private var shopCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        if let tz = TimeZone(identifier: "America/New_York") {
            cal.timeZone = tz
        }
        return cal
    }
    
    var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
    
    var fullDayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    var monthDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    var isToday: Bool {
        shopCalendar.isDateInToday(date)
    }
    
    var isTomorrow: Bool {
        shopCalendar.isDateInTomorrow(date)
    }
    
    var daysFromNow: Int {
        let today = shopCalendar.startOfDay(for: Date())
        let target = shopCalendar.startOfDay(for: date)
        return shopCalendar.dateComponents([.day], from: today, to: target).day ?? 0
    }
    
    var body: some View {
        NavigationLink(destination: TimeSlotView(date: date)) {
            HStack(spacing: 16) {
                // Date Badge
                VStack(spacing: 2) {
                    Text(dayName)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .tracking(1)
                        .foregroundColor(isToday ? .white : AppTheme.accent)
                    
                    Text(dayNumber)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(isToday ? .white : AppTheme.textPrimary)
                }
                .frame(width: 56, height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isToday ? AppTheme.accentGradient : LinearGradient(colors: [AppTheme.backgroundElevated], startPoint: .top, endPoint: .bottom))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isToday ? Color.clear : AppTheme.accent.opacity(0.2), lineWidth: 1)
                )
                
                // Date Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(fullDayName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        if isToday {
                            Text("Today")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(AppTheme.success.opacity(0.15))
                                .foregroundColor(AppTheme.success)
                                .cornerRadius(4)
                        } else if isTomorrow {
                            Text("Tomorrow")
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(AppTheme.accent.opacity(0.1))
                                .foregroundColor(AppTheme.accent)
                                .cornerRadius(4)
                        }
                    }
                    
                    HStack(spacing: 6) {
                        Text(monthDay)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Text("•")
                            .foregroundColor(AppTheme.textMuted)
                        
                        Text("4 slots open")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.success)
                    }
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(16)
            .background(AppTheme.backgroundCard)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DateSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppTheme.backgroundPrimary.ignoresSafeArea()
            NavigationView {
                DateSelectionView()
                    .environmentObject(BookingViewModel())
            }
        }
    }
}
