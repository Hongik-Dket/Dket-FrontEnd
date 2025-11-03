//
//  ResaleSuccessAlert.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import SwiftUI

struct ResaleSuccessAlert: View {
    let onConfirm: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            // 반투명 배경
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // 상단 x 버튼
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(6)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Group {
                        Text("최종 판매 요청 후에는 ")
                        + Text("취소가 불가능합니다.").foregroundColor(.dketBlue).fontWeight(.bold)

                        Text("구매자가 있을 경우 입력하신 금액으로 ")
                        + Text("즉시 자동 거래").foregroundColor(.dketBlue).fontWeight(.bold)
                        + Text("되며,\n별도의 승인 절차는 없습니다.")

                        Text("거래된 티켓은 ")
                        + Text("더 이상 조회할 수 없습니다.").foregroundColor(.dketBlue).fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)

                Button(action: onConfirm) {
                    Text("판매하기")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: 48)
                        .background(Color.dketBlue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 16)

                Spacer().frame(height: 10)
            }
            .padding(.top, 20)
            .padding(.bottom, 15)
            .background(Color.white)
            .cornerRadius(20)
            .frame(maxWidth: 300)
            .shadow(radius: 8)
        }
    }
}
