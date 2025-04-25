//
//  StepIndicatorView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/25/25.
//

import SwiftUI

struct StepIndicatorView: View {
    let current: EventSetupView.Step

    var body: some View {
        HStack(spacing: 0) {
            indicator("STEP 1", isActive: current == .one)
            indicator("STEP 2", isActive: current == .two)
            indicator("STEP 3", isActive: current == .three)
        }
        .frame(height: 50)
    }

    private func indicator(_ text: String, isActive: Bool) -> some View {
        Text(text)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(isActive ? .white : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                isActive
                    ? Color(red: 22/255, green: 29/255, blue: 111/255)
                    : Color.clear
            )
    }
}
