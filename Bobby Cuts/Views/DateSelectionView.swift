import SwiftUI

struct DateSelectionView: View {
    @EnvironmentObject var viewModel: BookingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select a Date")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
                .padding(.top)
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.getAvailableDates(), id: \.self) { date in
                        DateCard(date: date)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct DateCard: View {
    @EnvironmentObject var viewModel: BookingViewModel
    let date: Date
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
    
    var availableSlotsCount: Int {
        viewModel.getAvailableSlots(for: date).count
    }
    
    var body: some View {
        NavigationLink(destination: TimeSlotView(date: date)) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dateString)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(availableSlotsCount) slots available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}
