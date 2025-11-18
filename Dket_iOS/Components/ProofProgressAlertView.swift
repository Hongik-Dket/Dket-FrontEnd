//
//  ProofProgressAlertView.swift
//  Dket_iOS
//
//  Created by M-136 on 11/16/25.
//
import SwiftUI

// ✅ 검증 중 알림창
struct ProofProgressAlertView: View {
    let title: String
    let message: String

    var body: some View {
        ZStack {
            // 반투명 배경
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // 로고 or 아이콘
                Image("DketEmpty")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 75)
                    .padding(.top, 10)

                // 텍스트
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)

                    Text(message)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }

                // ✅ 진행 상태 표시 (로딩 인디케이터)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.dketBlue))
                    .scaleEffect(1.2)
                    .padding(.top, 6)
            }
            .padding(.vertical, 24)
            .frame(maxWidth: 300)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
        }
    }
}

// ✅ 검증 실패 알림창
struct ProofFailedAlertView: View {
    let title: String
    let message: String
    let retryButtonTitle: String
    let onRetry: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            // 배경 반투명 오버레이
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // 상단 닫기 버튼
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 4)
                }

                // 로고 or 아이콘
                Image("DketEmpty")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 75)
                    .padding(.top, -10)

                // 텍스트
                VStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)
                    Text(message)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }

                // 재시도 버튼
                Button(action: onRetry) {
                    Text(retryButtonTitle)
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(Color.dketBlue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
            .padding(.vertical, 16)
            .frame(maxWidth: 300)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
        }
    }
}
