//
//  Theme.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import SwiftUI

// MARK: - App Colors

struct AppColors {
    // Primary brand
    static let primary = Color(red: 0.32, green: 0.78, blue: 0.64)       // Teal-green
    static let primaryDark = Color(red: 0.20, green: 0.60, blue: 0.48)
    
    // Semantic
    static let owedToYou = Color(red: 0.30, green: 0.75, blue: 0.55)     // Green
    static let youOwe = Color(red: 0.93, green: 0.42, blue: 0.36)        // Red-orange
    static let settled = Color.secondary
    
    // Backgrounds
    static let background = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    static let groupedBackground = Color(UIColor.systemGroupedBackground)
    
    // Surface
    static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
    
    // Text
    static let primaryText = Color(UIColor.label)
    static let secondaryText = Color(UIColor.secondaryLabel)
    static let tertiaryText = Color(UIColor.tertiaryLabel)
    
    // Accent avatars
    static let avatarColors: [Color] = [
        Color(red: 0.32, green: 0.78, blue: 0.64),
        Color(red: 0.55, green: 0.47, blue: 0.87),
        Color(red: 0.95, green: 0.60, blue: 0.30),
        Color(red: 0.40, green: 0.70, blue: 0.95),
        Color(red: 0.90, green: 0.45, blue: 0.65),
        Color(red: 0.75, green: 0.65, blue: 0.30),
        Color(red: 0.55, green: 0.80, blue: 0.45),
        Color(red: 0.85, green: 0.50, blue: 0.85),
    ]
    
    static func avatarColor(for index: Int) -> Color {
        avatarColors[index % avatarColors.count]
    }
}

// MARK: - Typography

struct AppTypography {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
    
    static let amountLarge = Font.system(size: 40, weight: .bold, design: .rounded)
    static let amountMedium = Font.system(size: 24, weight: .bold, design: .rounded)
    static let amountSmall = Font.system(size: 17, weight: .semibold, design: .monospaced)
}

// MARK: - Spacing & Sizing

struct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
}

struct AppRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let full: CGFloat = 999
}

// MARK: - View Modifiers

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppSpacing.lg)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(AppColors.primary)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.headline)
            .foregroundStyle(AppColors.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(AppColors.primary, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}

// MARK: - Currency Formatter

struct CurrencyFormatter {
    static func format(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: abs(amount))) ?? "₹0.00"
    }
    
    static func formatSigned(_ amount: Double) -> String {
        if amount > 0 {
            return "+\(format(amount))"
        } else if amount < 0 {
            return "-\(format(amount))"
        }
        return format(0)
    }
}
