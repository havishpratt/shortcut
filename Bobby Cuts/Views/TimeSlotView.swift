import SwiftUI

struct TimeSlotView: View {
    @EnvironmentObject var viewModel: BookingViewModel
    let date: Date
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Available Times")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            Text(dateString)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(viewModel.getAvailableSlots(for: date)) { slot in
                        NavigationLink(destination: BookingFormView(slot: slot)) {
                            Text(slot.displayTime)
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Select Time")
        .navigationBarTitleDisplayMode(.inline)
    }
}
