//
//  PassportInfoView.swift
//  Dket_iOS
//
//  Created by M-136 on 11/16/25.
//

import SwiftUI

struct PassportInfoView: View {
    let info: PassportInfoDTO
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Image("TicketDetail")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Text("여권 정보 조회")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.dketBlue)
                    .padding(.top, 80)

                VStack(alignment: .leading, spacing: 10) {
                    TicketInfoRow(label: "여권 번호", value: info.passportNumber)
                    TicketInfoRow(label: "성별", value: info.gender)
                    TicketInfoRow(label: "영문 성", value: info.lastName)
                    TicketInfoRow(label: "영문 이름", value: info.firstName)
                    TicketInfoRow(label: "생년월일", value: info.birth)
                    TicketInfoRow(label: "국적", value: info.nationality)
                    TicketInfoRow(label: "여권 만료일", value: info.passportExpiry)
                }
                .padding(.horizontal, 50)
                .padding(.top, 20)

                Spacer()
            }

            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.white.opacity(0.7))
                            .clipShape(Circle())
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
        }
    }
}

struct PassportErrorView: View {
    var body: some View {
        ZStack {
            Image("TicketDetail")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer().frame(height: 100)
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40))
                    .foregroundColor(.dketBlue)

                Text("영지식 증명(ZKP) 생성 중 오류가 발생했습니다.\n공연장 스태프의 안내에 따라\n오프라인 본인인증을 진행해주세요.")
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black.opacity(0.8))
                    .padding(.horizontal, 20)
                Spacer()
            }
        }
    }
}
