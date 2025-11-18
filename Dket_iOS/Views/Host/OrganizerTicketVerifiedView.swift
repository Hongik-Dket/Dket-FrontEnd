//
//  OrganizerTicketVerifiedView.swift.swift
//  Dket_iOS
//
//  Created by M-136 on 11/18/25.
//

import SwiftUI

struct OrganizerTicketVerifiedView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var showScanner: Bool

    var body: some View {
        ZStack {
            // ✅ 배경
            Image("TicketDetail")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                // ✅ 상단 닫기 버튼
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .padding(12)
                    }
                }
                .padding(.trailing, 20)
                .padding(.top, 16)

                Spacer()

                // ✅ 중앙 콘텐츠
                VStack(spacing: 16) {
                    // 🎟️ 티켓 카드 (체크 아이콘 제거)
                    Image("EntrySuccess")
                        .resizable()
                        .frame(width: 296, height: 122)
                        .padding(.bottom, 8)

                    // ✅ 안내 텍스트
                    Text("티켓 검증이 완료되었습니다.\n입장을 진행해주세요.")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 22/255, green: 29/255, blue: 111/255))
                        .padding(.top, 8)
                }
                .padding(.bottom, 80)

                Spacer()

                // ✅ 하단 버튼
                Button {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        showScanner = true
                    }
                } label: {
                    Text("다른 티켓 확인하기")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 344, height: 48)
                        .background(Color(red: 22/255, green: 29/255, blue: 111/255))
                        .cornerRadius(24)
                        .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview("티켓 검증 완료") {
    OrganizerTicketVerifiedView(showScanner: .constant(false))
        .previewDevice("iPhone 15 Pro")
}
