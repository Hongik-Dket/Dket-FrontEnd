//
//  PrimaryButton.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/8/25.
//
import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    var width: CGFloat? = nil
    var height: CGFloat = 50

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: width ?? .infinity, minHeight: height)
                .background(isDisabled ? Color.gray.opacity(0.4) : Color.dketBlue)
                .cornerRadius(12)
        }
        .disabled(isDisabled)
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

