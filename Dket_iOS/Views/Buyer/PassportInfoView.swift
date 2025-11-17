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
            // 배경 이미지
            Image("TicketDetail")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                Spacer()

                // 본문 정보 영역
                VStack(alignment: .center, spacing: 12) {
                    TicketInfoRow(label: "여권 번호", value: info.passportNumber)
                    TicketInfoRow(label: "성별", value: info.gender)
                    TicketInfoRow(label: "영문 성", value: info.lastName)
                    TicketInfoRow(label: "영문 이름", value: info.firstName)
                    TicketInfoRow(label: "생년월일", value: info.birth)
                    TicketInfoRow(label: "국적", value: info.nationality)
                    TicketInfoRow(label: "여권 만료일", value: info.passportExpiry)
                }
                .font(.system(size: 16, weight: .medium))
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.vertical, 24)
                .background(Color.white.opacity(0.8))
                .cornerRadius(16)
                .shadow(radius: 5)
                .padding(.horizontal, 32)

                Spacer()
            }

            // 닫기 버튼 (우상단)
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


