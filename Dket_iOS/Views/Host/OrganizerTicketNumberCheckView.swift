//
//  OrganizerTicketNumberCheckView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

import SwiftUI

struct OrganizerTicketNumberCheckView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var ticketNumber: String = ""
    @State private var isSearching = false
    @State private var selectedTicket: TicketDetail?

    var body: some View {
        VStack(spacing: 0) {
            BackHeaderView(onBack: { dismiss() }, onMenu: {})
            Spacer()

            // 🎟 티켓 번호 입력 필드
            ZStack {
                Image("TicketNumberCheck")
                    .resizable()
                    .frame(width: 350, height: 150)
                    .shadow(radius: 2)

                TextField("티켓 번호를 입력하세요", text: $ticketNumber)
                    .foregroundColor(.dketMint)
                    .font(.system(size: 24, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .frame(width: 280, height: 48) // ✅ 중앙 정렬을 위해 고정 너비 지정
                    .background(Color.clear)
                    .overlay(
                        Rectangle()
                            .frame(height: 5)
                            .foregroundColor(.dketMint),
                        alignment: .bottom
                    )
            }
            .padding(.vertical, 40)

            Spacer()

            // 조회 버튼
            VStack(spacing: 12) {
                Button {
                    // 👉 여기에 조회 API 호출 또는 ViewModel 연동
                    withAnimation {
                        isSearching = true

                        // 예시 데이터
                        selectedTicket = TicketDetail(
                            id: 1,
                            title: "뮤지컬 고흐",
                            dateFormatted: "2025.03.20 18:00",
                            userName: "여희주",
                            userBirth: "2003.02.25",
                            ticketNumber: ticketNumber,
                            seat: "39",
                            qrCodeUrl: nil
                        )
                    }
                } label: {
                    Text("티켓 조회하기")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.dketMint)
                        .frame(maxWidth: 360, maxHeight: 48)
                        .background(ticketNumber.isEmpty ? Color.gray : Color.dketBlue)
                        .cornerRadius(24)
                        .shadow(radius: 4)
                }
                .disabled(ticketNumber.isEmpty)

                Button {
                    // QR 코드로 확인 뷰로 돌아가기
                    dismiss()
                } label: {
                    Text("QR 코드로 확인하기")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.dketMint)
                        .frame(maxWidth: 360, maxHeight: 48)
                        .background(Color.dketBlue)
                        .cornerRadius(24)
                        .shadow(radius: 4)
                }
            }
            .padding(.bottom, 40)
        }
        .background(Color.white)
        .navigationDestination(isPresented: Binding<Bool>(
            get: { selectedTicket != nil },
            set: { if !$0 { selectedTicket = nil } }
        )) {
            if let ticket = selectedTicket {
                OrganizerTicketDetailView(ticket: ticket)
            }
        }
    }
}

struct OrganizerTicketNumberCheckView_Previews: PreviewProvider {
    static var previews: some View {
        OrganizerTicketNumberCheckView()
            .environmentObject(AppState()) // AppState가 필요하다면 주입
    }
}
