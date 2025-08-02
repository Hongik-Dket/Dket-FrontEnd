//
//  EventSetupForm.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/25/25.
//

import SwiftUI

struct StepButton: View {
    let title: String
    let current: ConcertSetupView.Step
    @Binding var selected: ConcertSetupView.Step
    
    init(_ title: String, current: ConcertSetupView.Step, selected: Binding<ConcertSetupView.Step>) {
        self.title = title; self.current = current; self._selected = selected
    }
    
    var body: some View {
        Button(action: { selected = current }) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(selected == current ? .white : .gray)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(selected == current
                            ? Color.dketBlue
                            : Color.clear)
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var filled: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(filled ? .white : .gray)
            .font(.system(size: 16, weight: .bold))
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(filled
                        ? Color.dketBlue
                        : Color.gray.opacity(0.3))
            .cornerRadius(8)
    }
}

struct UnderlineTextFieldStyle: TextFieldStyle {
    var icon: String? = nil
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            configuration
            if let icon = icon {
                Image(systemName: icon)
            }
        }
        .padding(.vertical, 4)
        .overlay(Rectangle().frame(height: 1).padding(.top, 35), alignment: .bottom)
    }
}

struct AgeOptionButton: View {
    let title: String
    @Binding var selected: String?
    let value: String
    
    var body: some View {
        Button(action: { selected = value }) {
            Text(title)
                .font(.caption)
                .lineLimit(1)
                .fixedSize()
                .padding(.vertical, 6).padding(.horizontal, 8)
                .background(selected == value
                            ? Color.dketBlue.opacity(0.2)
                            : Color.gray.opacity(0.2))
                .foregroundColor(.black)
                .cornerRadius(6)
        }
    }
}
