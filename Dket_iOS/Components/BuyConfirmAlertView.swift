//
//  BuyConfirmAlertView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/17/25.
//

import SwiftUI

struct BuyConfirmAlertView: View {
    let priceEth: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                        .padding(4)
                        .background(Color.white)
                        .clipShape(Circle())
                }
            }

            Spacer().frame(height: 10)

            Image("DketEmpty")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)

            Text("티켓 가격은 다음과 같습니다:")
                .font(.body)

            Text("\(priceEth) ETH")
                .font(.title3).bold()
                .foregroundColor(Color.dketBlue)

            Text("결제를 진행하시겠습니까?")
                .font(.body)

            Button(action: onConfirm) {
                Text("결제하기")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 48)
                    .background(Color.dketBlue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            Spacer().frame(height: 10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .frame(maxWidth: 300)
        .shadow(radius: 8)
    }
}
