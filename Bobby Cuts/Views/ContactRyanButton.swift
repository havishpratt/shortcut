import SwiftUI

struct ContactRyanButton: View {
    @State private var showingOptions = false
    
    var body: some View {
        VStack{
            Button(action: {
                showingOptions = true
            }) {
                HStack {
                    Image(systemName: "phone.circle.fill")
                        .font(.title3)
                    Text("Contact Ryan")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .confirmationDialog("Contact Ryan", isPresented: $showingOptions, titleVisibility: .visible) {
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
                Text("Choose how you'd like to reach out")
            }
        }
        }
}

struct ContactRyanButton_Previews: PreviewProvider {
    static var previews: some View {
        ContactRyanButton()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
