import SwiftUI

struct TimeSlotView: View {
    @EnvironmentObject var viewModel: BookingViewModel
    let date: Date
    @State private var appeared = false
    
    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    var fullDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            AppBackground()
            
            VStack(spacing: 0) {
                // Header Card
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(dayName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text(fullDate)
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        // Calendar icon badge
                        ZStack {
                            Circle()
                                .fill(AppTheme.accent.opacity(0.1))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "calendar")
                                .font(.system(size: 22))
                                .foregroundColor(AppTheme.accent)
                        }
                    }
                    
                    // Service info
                    HStack(spacing: 16) {
                        HStack(spacing: 6) {
                            Image(systemName: "scissors")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                            Text("Haircut")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                            Text("1 Hour")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: "dollarsign.circle")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                            Text("$15")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
                .background(AppTheme.backgroundCard)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Section Title
                HStack {
                    Text("Pick a time")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 16)
                
                // Content
                if viewModel.isLoadingSlots {
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.accent))
                            .scaleEffect(1.2)
                        
                        Text("Checking availability...")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    Spacer()
                } else {
                    let slots = viewModel.getAvailableSlots(for: date)
                    
                    if slots.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Text("😅")
                                .font(.system(size: 50))
                            
                            Text("All Booked Up!")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text("No slots left for this day.\nTry another date!")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                ForEach(Array(slots.enumerated()), id: \.element.id) { index, slot in
                                    NavigationLink(destination: BookingFormView(slot: slot)) {
                                        TimeSlotCard(slot: slot)
                                            .opacity(appeared ? 1 : 0)
                                            .offset(y: appeared ? 0 : 20)
                                            .animation(
                                                .spring(response: 0.5, dampingFraction: 0.7)
                                                .delay(Double(index) * 0.08),
                                                value: appeared
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadAvailability(for: date)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
}

struct TimeSlotCard: View {
    let slot: TimeSlot
    
    var body: some View {
        VStack(spacing: 8) {
            Text(slot.displayTime)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)
            
            Text("Available")
                .font(.caption)
                .foregroundColor(AppTheme.success)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(AppTheme.backgroundCard)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.accent.opacity(0.15), lineWidth: 1)
        )
    }
}

struct TimeSlotView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TimeSlotView(date: Date())
                .environmentObject(BookingViewModel())
        }
    }
}