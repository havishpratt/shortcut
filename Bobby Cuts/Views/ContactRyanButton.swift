import SwiftUI

struct ContactRyanButton: View {
    @State private var showingOptions = false
    
    var body: some View {
        Button(action: {
            showingOptions = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "message.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                
                Text("Text Bobby")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(AppTheme.success)
            .cornerRadius(16)
            .shadow(color: AppTheme.success.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .confirmationDialog("Contact Bobby", isPresented: $showingOptions, titleVisibility: .visible) {
            Button("Call") {
                if let url = URL(string: "tel://1234567890") {
                    UIApplication.shared.open(url)
                }
            }
            Button("Text Message") {
                if let url = URL(string: "sms://1234567890") {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("How do you want to reach Bobby?")
        }
    }
}

struct ContactRyanButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppBackground()
            ContactRyanButton()
                .padding()
        }
    }
}
