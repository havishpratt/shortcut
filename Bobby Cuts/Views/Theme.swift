import SwiftUI

// MARK: - App Theme
struct AppTheme {
    // Primary Colors - Fresh, casual college vibe
    static let accent = Color(red: 0.35, green: 0.65, blue: 0.95) // Friendly blue
    static let accentLight = Color(red: 0.55, green: 0.78, blue: 1.0)
    static let accentDark = Color(red: 0.25, green: 0.50, blue: 0.80)
    
    // Background Colors - Clean and modern
    static let backgroundPrimary = Color(red: 0.98, green: 0.98, blue: 1.0)
    static let backgroundSecondary = Color(red: 0.94, green: 0.94, blue: 0.96)
    static let backgroundCard = Color.white
    static let backgroundElevated = Color(red: 0.96, green: 0.96, blue: 0.98)
    
    // Text Colors
    static let textPrimary = Color(red: 0.15, green: 0.15, blue: 0.20)
    static let textSecondary = Color(red: 0.45, green: 0.45, blue: 0.50)
    static let textMuted = Color(red: 0.65, green: 0.65, blue: 0.70)
    
    // Accent Colors
    static let success = Color(red: 0.30, green: 0.75, blue: 0.45)
    static let warning = Color(red: 0.95, green: 0.65, blue: 0.25)
    static let error = Color(red: 0.90, green: 0.35, blue: 0.35)
    
    // Gradients
    static let accentGradient = LinearGradient(
        colors: [accentLight, accent, accentDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = LinearGradient(
        colors: [backgroundCard, backgroundSecondary],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Custom Button Styles
struct AccentButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Group {
                    if isEnabled {
                        AppTheme.accentGradient
                    } else {
                        Color.gray.opacity(0.4)
                    }
                }
            )
            .cornerRadius(14)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.medium)
            .foregroundColor(AppTheme.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.accent.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppTheme.accent.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(14)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Custom Card Modifier
struct CardModifier: ViewModifier {
    var padding: CGFloat = 20
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppTheme.backgroundCard)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

extension View {
    func cardStyle(padding: CGFloat = 20) -> some View {
        modifier(CardModifier(padding: padding))
    }
}

// MARK: - Simple Background
struct AppBackground: View {
    var body: some View {
        AppTheme.backgroundPrimary
            .ignoresSafeArea()
    }
}

// MARK: - Decorative Elements
struct ScissorsIcon: View {
    var size: CGFloat = 24
    var color: Color = AppTheme.accent
    
    var body: some View {
        Image(systemName: "scissors")
            .font(.system(size: size, weight: .light))
            .foregroundColor(color)
    }
}

struct DividerLine: View {
    var body: some View {
        Rectangle()
            .fill(AppTheme.textMuted.opacity(0.3))
            .frame(height: 1)
            .padding(.horizontal, 40)
    }
}

// Keep old name for compatibility
typealias GoldButtonStyle = AccentButtonStyle
typealias AnimatedMeshBackground = AppBackground
