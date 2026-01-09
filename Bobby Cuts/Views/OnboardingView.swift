import SwiftUI
import AuthenticationServices

struct OnboardingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            AppBackground()
            
            switch authViewModel.currentStep {
            case .welcome:
                WelcomeView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case .phoneNumber:
                PhoneNumberView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
    }
}

// MARK: - Welcome View

struct WelcomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Logo and Title
            VStack(spacing: 20) {
                Text("✂️")
                    .font(.system(size: 80))
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                
                VStack(spacing: 8) {
                    Text("Barber Cuts")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("Premium Grooming Experience")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)
            }
            
            Spacer()
            
            // Sign In Buttons
            VStack(spacing: 16) {
                // Sign in with Apple
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        authViewModel.handleAppleSignIn(result: result)
                    }
                )
                .signInWithAppleButtonStyle(.white)
                .frame(height: 54)
                .cornerRadius(14)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: appeared)
                
                // Sign in with Google
                Button(action: {
                    authViewModel.handleGoogleSignIn()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "g.circle.fill")
                            .font(.system(size: 20))
                        
                        Text("Sign in with Google")
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(AppTheme.backgroundCard)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(AppTheme.textMuted.opacity(0.3), lineWidth: 1)
                    )
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: appeared)
                
                // Error message
                if let error = authViewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(AppTheme.error)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            
            // Terms text
            Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                .font(.caption)
                .foregroundColor(AppTheme.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4), value: appeared)
        }
        .overlay {
            if authViewModel.isLoading {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .onAppear {
            withAnimation {
                appeared = true
            }
        }
    }
}

// MARK: - Phone Number View

struct PhoneNumberView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var appeared = false
    @FocusState private var isPhoneFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    withAnimation {
                        authViewModel.currentStep = .welcome
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                        .frame(width: 44, height: 44)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            Spacer()
            
            // Content
            VStack(spacing: 32) {
                // Icon
                ZStack {
                    Circle()
                        .fill(AppTheme.accent.opacity(0.15))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "phone.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.accent)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                
                // Title
                VStack(spacing: 8) {
                    Text("Your Phone Number")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("We'll use this to send you booking confirmations")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)
                
                // Phone Input
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        // US Flag
                        Text("🇺🇸")
                            .font(.title2)
                        
                        Text("+1")
                            .font(.headline)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        // Divider
                        Rectangle()
                            .fill(AppTheme.textMuted.opacity(0.3))
                            .frame(width: 1, height: 24)
                        
                        // Phone number field
                        TextField("", text: Binding(
                            get: { authViewModel.formattedPhoneNumber },
                            set: { authViewModel.formatPhoneNumber($0) }
                        ), prompt: Text("(555) 123-4567").foregroundColor(AppTheme.textMuted))
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(AppTheme.textPrimary)
                            .keyboardType(.phonePad)
                            .focused($isPhoneFocused)
                    }
                    .padding(20)
                    .background(AppTheme.backgroundCard)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isPhoneFocused ? AppTheme.accent : AppTheme.textMuted.opacity(0.2), lineWidth: isPhoneFocused ? 2 : 1)
                    )
                }
                .padding(.horizontal, 24)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: appeared)
            }
            
            Spacer()
            
            // Continue Button
            Button(action: {
                authViewModel.completeOnboarding()
            }) {
                HStack {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Get Started")
                        Image(systemName: "arrow.right")
                    }
                }
            }
            .buttonStyle(AccentButtonStyle(isEnabled: authViewModel.isPhoneNumberValid))
            .disabled(!authViewModel.isPhoneNumberValid || authViewModel.isLoading)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: appeared)
        }
        .onAppear {
            withAnimation {
                appeared = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isPhoneFocused = true
            }
        }
        .onTapGesture {
            isPhoneFocused = false
        }
    }
}

// MARK: - Previews

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(AuthViewModel())
    }
}
