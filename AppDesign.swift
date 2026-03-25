//
//  AppDesign.swift
//  NutriCore
//
//  Created by Mukunth Parthasarathy on 25/03/2026.
//

import SwiftUI

struct AppCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
            .padding(.horizontal)
    }
}

extension View {
    func appCard() -> some View {
        modifier(AppCardModifier())
    }
}

struct AppGradientBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.12),
                    Color.purple.opacity(0.08),
                    Color(.systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            content
        }
    }
}

extension View {
    func appBackground() -> some View {
        modifier(AppGradientBackground())
    }
}
