//
//  ResaleInfoPopupView.swift
//  Dket_iOS
//
//  Created by 이지우 on 8/21/25.
//

import SwiftUI

struct ResaleInfoPopup: View {
    var onClose: () -> Void

    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 16) {
                    // 첫 문단
                    Text("리세일 티켓은 정가의 ")
                        .font(.body) +
                    Text("최대 120%")
                        .foregroundColor(.blue)
                        .font(.body).bold() +
                    Text("까지 가격 설정이 가능하며,\n") +
                    Text("초과 금액의 10%")
                        .foregroundColor(.blue)
                        .font(.body).bold() +
                    Text("는 공연 개최자에게 수익으로 분배됩니다.")

                    // 두 번째 문단
                    Text("입장 마감된 티켓은 금액 제한 없이 판매할 수 있고, ") +
                    Text("판매가의 10%")
                        .foregroundColor(.blue)
                        .font(.body).bold() +
                    Text("가 개최자에게 분배됩니다.")
                }
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(radius: 10)

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .padding(8)
                }
                .padding(8)
            }

            Button(action: onClose) {
                Text("확인했습니다")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.dketBlue)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .padding()
        .frame(maxWidth: 320)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 12)
    }
}
