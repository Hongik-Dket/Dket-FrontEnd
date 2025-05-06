//
//  QRScannerContainerView.swift
//  Dket_iOS
//
//  Created by 이지우 on 5/6/25.
//

import SwiftUI

/// QRScanView 위에 UI를 얹는 SwiftUI 컨테이너
struct QRScannerContainerView: View {
    @Environment(\.dismiss) private var dismiss
    let onScan: (String) -> Void
    let onManualTap: () -> Void

    var body: some View {
        ZStack {
            // 1️⃣ 카메라 프리뷰
            QRScanView(onScan: onScan)
                .edgesIgnoringSafeArea(.all)

            // 2️⃣ 상단 뒤로가기
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.top, 44)    // notch / status bar 감안
                .padding(.horizontal, 16)

                Spacer()

                // 3️⃣ 하단 수동 입력 버튼
                Button("티켓 번호로 확인하기") {
                    onManualTap()
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: 360, maxHeight: 48)
                .background(Color(red: 22/255, green: 29/255, blue: 111/255))
                .cornerRadius(24)
                .shadow(radius: 4)
            }
        }
    }
}
