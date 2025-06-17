////
////  OrganizerTicketDetailView.swift
////  Dket_iOS
////
////  Created by 이지우 on 6/15/25.
////
//

import SwiftUI

struct OrganizerTicketDetailView: View {
    let ticket: TicketDetail
    var onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let service: TicketServicing = TicketService()

    var body: some View {
        ZStack {
            Image("TicketDetail")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .padding(20)
                    }
                }
                .padding(.trailing, 16)

                VStack(spacing: 20) {
                    Text(ticket.eventTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.dketBlue)

                    VStack(alignment: .leading, spacing: 10) {
                        TicketInfoRow(label: "공연 일시", value: ticket.startDateFormatted)
                        TicketInfoRow(label: "예매자 명", value: ticket.buyerName)
                        TicketInfoRow(label: "생년월일", value: ticket.birthDateFormatted)
                        TicketInfoRow(label: "티켓 번호", value: ticket.ticketNumber)
                        TicketInfoRow(label: "좌석 번호", value: ticket.seatNumber)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 50)
                }
                .padding(.top, 170)

                Spacer()

                Button {
                    Task {
                        do {
                            try await service.enterTicket(ticket.ticketId)
                            alertMessage = "입장 처리되었습니다."
                        } catch {
                            alertMessage = error.localizedDescription
                        }
                        showAlert = true
                    }
                } label: {
                    Text("입장 완료")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: 360, maxHeight: 48)
                        .background(Color.dketBlue)
                        .cornerRadius(24)
                        .shadow(radius: 4)
                }
                .padding(.bottom, 60)
                .alert("알림", isPresented: $showAlert) {
                    Button("확인") {
                        onDismiss()
                    }
                } message: {
                    Text(alertMessage)
                }
            }
        }
    }
}

