import SwiftUI
import AuthenticationServices
import Combine
import Supabase

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isOnboarding = true
    @Published var currentStep: OnboardingStep = .welcome
    @Published var phoneNumber = ""
    @Published var formattedPhoneNumber = ""
    @Published var userName = ""
    @Published var userEmail = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    enum OnboardingStep {
        case welcome
        case confirmProfile
        case phoneNumber
    }
    
    init() {
        // Check if user has completed onboarding before
        if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
            isOnboarding = false
            isAuthenticated = true
            loadUserData()
        }
    }
    
    // MARK: - Phone Number Formatting
    
    func formatPhoneNumber(_ input: String) {
        // Remove all non-numeric characters
        let digits = input.filter { $0.isNumber }
        
        // Limit to 10 digits
        let limitedDigits = String(digits.prefix(10))
        phoneNumber = limitedDigits
        
        // Format as (XXX) XXX-XXXX
        var formatted = ""
        for (index, digit) in limitedDigits.enumerated() {
            if index == 0 {
                formatted += "("
            }
            if index == 3 {
                formatted += ") "
            }
            if index == 6 {
                formatted += "-"
            }
            formatted += String(digit)
        }
        formattedPhoneNumber = formatted
    }
    
    var isPhoneNumberValid: Bool {
        phoneNumber.count == 10
    }
    
    var isProfileValid: Bool {
        !userName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !userEmail.trimmingCharacters(in: .whitespaces).isEmpty &&
        userEmail.contains("@")
    }
    
    // MARK: - Apple Sign In
    
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        isLoading = true
        errorMessage = nil
        
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                // Extract user info
                if let fullName = appleIDCredential.fullName {
                    let firstName = fullName.givenName ?? ""
                    let lastName = fullName.familyName ?? ""
                    userName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
                }
                
                if let email = appleIDCredential.email {
                    userEmail = email
                }
                
                // Move to profile confirmation step
                withAnimation {
                    currentStep = .confirmProfile
                }
            }
            isLoading = false
            
        case .failure(let error):
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Google Sign In
    
    func handleGoogleSignIn() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // 1. Generate the URL that starts the Google Login flow
                let url = try await supabase.auth.getOAuthSignInURL(
                    provider: .google,
                    redirectTo: URL(string: "com.prattipati.barbercuts://google-callback")
                )
                
                // 2. Open that URL in Safari
                await MainActor.run {
                    UIApplication.shared.open(url)
                    isLoading = false // We stop loading here because the app will close to open Safari
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to start Google Sign In: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Handle Google Callback
    
    func handleGoogleCallback(session: Session) {
        // Extract user info from session
        if let email = session.user.email {
            userEmail = email
        }
        
        // Try to get name from user metadata - Google provides various fields
        let metadata = session.user.userMetadata
        print("📋 User metadata: \(metadata)")
        
        if let fullName = metadata["full_name"]?.stringValue {
            userName = fullName
        } else if let name = metadata["name"]?.stringValue {
            userName = name
        } else if let givenName = metadata["given_name"]?.stringValue {
            let familyName = metadata["family_name"]?.stringValue ?? ""
            userName = "\(givenName) \(familyName)".trimmingCharacters(in: .whitespaces)
        }
        
        print("👤 Extracted - Name: \(userName), Email: \(userEmail)")
        
        // Move to profile confirmation step
        withAnimation {
            currentStep = .confirmProfile
        }
    }
    
    // MARK: - Confirm Profile
    
    func confirmProfile() {
        guard isProfileValid else { return }
        
        // Save the confirmed profile data
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(userEmail, forKey: "userEmail")
        
        withAnimation {
            currentStep = .phoneNumber
        }
    }
    
    // MARK: - Complete Onboarding
    
    func completeOnboarding() {
        guard isPhoneNumberValid else { return }
        
        isLoading = true
        
        // Save user data
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(userEmail, forKey: "userEmail")
        UserDefaults.standard.set(phoneNumber, forKey: "userPhone")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
            withAnimation(.easeInOut(duration: 0.3)) {
                self.isOnboarding = false
                self.isAuthenticated = true
            }
        }
    }
    
    // MARK: - Load Saved Data
    
    private func loadUserData() {
        userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        phoneNumber = UserDefaults.standard.string(forKey: "userPhone") ?? ""
        formatPhoneNumber(phoneNumber)
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        withAnimation {
            isAuthenticated = false
            isOnboarding = true
            currentStep = .welcome
            phoneNumber = ""
            formattedPhoneNumber = ""
            userName = ""
            userEmail = ""
        }
    }
}
