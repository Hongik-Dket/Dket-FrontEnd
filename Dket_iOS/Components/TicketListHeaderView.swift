//
//  TicketListHeaderView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

import SwiftUI

struct TicketListHeaderView: View {
    var title: String
    var onBack: () -> Void
    var onMenu: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.black)
            }

            Spacer()

            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)

            Spacer()

            Button(action: onMenu) {
                Image(systemName: "line.horizontal.3")
                    .font(.title2)
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 50)
        .background(Color.white)
    }
}
