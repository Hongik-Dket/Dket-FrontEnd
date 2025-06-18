//
//  BackHeaderView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/24/25.
//

import SwiftUI

struct BackHeaderView: View {
    var onBack: () -> Void
    var onMenu: () -> Void
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.top)
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Spacer()
                Image("Dket")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
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
        .frame(height: 50)
    }
}
