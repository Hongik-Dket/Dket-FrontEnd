//
//  BuyerMyPageView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

import SwiftUI

struct BuyerMypageView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // 상단 헤더
            BackHeaderView(
                onBack: { dismiss() },
                onMenu: {
                    // 마이페이지 내 메뉴 버튼은 기능 없음 or future action
                }
            )

            Divider()

            VStack(alignment: .leading, spacing: 40) {
                MypageRow(title: "내 지갑 정보")
                MypageRow(title: "MY 티켓")
                MypageRow(title: "MY 포토카드")
                MypageRow(title: "로그아웃")
                MypageRow(title: "서비스 탈퇴")
                MypageRow(title: "이용약관")
                MypageRow(title: "개최자 모드로 전환")
            }
            .padding(.horizontal, 20)
            .padding(.top, 32)

            Spacer()
        }
        .background(Color.white)
        .navigationBarBackButtonHidden()
    }
}

struct BuyerMypageView_Previews: PreviewProvider {
    static var previews: some View {
        BuyerMypageView()
    }
}
