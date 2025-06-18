//
//  MyPageRow.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

import SwiftUI

struct MypageRow: View {
    let title: String
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.dketBlue)
                    .frame(width: 8, height: 8)

                Text(title)
                    .foregroundColor(.black)
                    .font(.system(size: 17, weight: .semibold))

                Spacer()
            }
        }
    }
}
