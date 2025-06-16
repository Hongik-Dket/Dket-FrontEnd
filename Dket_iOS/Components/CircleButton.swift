//
//  CircleButton.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/17/25.
//

import SwiftUI

struct CircleButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    var width: CGFloat? = nil
    var height: CGFloat = 50

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: 48)
                .background(isDisabled ? Color.gray.opacity(0.4) : Color.dketBlue)
                .cornerRadius(24)
                .shadow(radius: 4)
                .padding(.horizontal)
        }
        .disabled(isDisabled)
    }
}
