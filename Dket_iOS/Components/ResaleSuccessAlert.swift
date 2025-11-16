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
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // 상단 닫기 버튼
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(6)
                            .background(Color.white.opacity(0.001)) // 터치 영역 확장
                    }
                }
                .padding(.trailing, 4)

                VStack(spacing: 12) {
                    Group {
                        (Text("지금 판매를 진행하면 즉시 거래가 체결되며,\n이후 ")
                        + Text("취소는 불가능합니다.")
                            .foregroundColor(.dketBlue)
                            .fontWeight(.bold))

                        (Text("구매자가 있을 경우 ")
                        + Text("바로 정산이 진행")
                            .foregroundColor(.dketBlue)
                            .fontWeight(.bold)
                        + Text("되니\n판매가를 다시 한 번 확인해주세요."))
                    }
                    .font(.system(size: 15))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                }
                .padding(.horizontal, 24)

                Button(action: onConfirm) {
                    Text("판매하기")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.dketBlue)
                        .cornerRadius(5)
                }
                .padding(.horizontal, 24)
                .padding(.top, 4)
            }
            .padding(.vertical, 40)
            .frame(maxWidth: 310)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 8)
        }
    }
}

struct ResaleSuccessAlert_Previews: PreviewProvider {
    static var previews: some View {
        ResaleSuccessAlert(
            onConfirm: { print("판매하기 버튼 클릭") },
            onClose: { print("닫기 버튼 클릭") }
        )
        .preferredColorScheme(.light)
    }
}
