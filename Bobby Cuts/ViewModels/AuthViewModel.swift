import SwiftUI
import AuthenticationServices
import Combine

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
                
                // Move to phone number step
                withAnimation {
                    currentStep = .phoneNumber
                }
            }
            isLoading = false
            
        case .failure(let error):
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Google Sign In (Placeholder)
    
    func handleGoogleSignIn() {
        isLoading = true
        errorMessage = nil
        
        // TODO: Implement actual Google Sign In
        // For now, simulate success and move to phone step
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            withAnimation {
                self.currentStep = .phoneNumber
            }
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
