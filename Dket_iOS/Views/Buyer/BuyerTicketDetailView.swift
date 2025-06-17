//
//  TicketDetailView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/14/25.
//

import SwiftUI

struct BuyerTicketDetailView: View {
    @StateObject private var vm: BuyerTicketDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showPhotoCard = false

    init(ticketId: Int64) {
        print("🧾 BuyerTicketDetailView INIT with ticketId: \(ticketId)")
        _vm = StateObject(wrappedValue: BuyerTicketDetailViewModel(ticketId: ticketId))
    }

    var body: some View {
        ZStack {
            Image("TicketDetail")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            if let ticket = vm.ticket {
                VStack(spacing: 12) {
                    Text(ticket.eventTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.dketBlue)
                        .padding(.top, 120)

                    VStack(alignment: .leading, spacing: 10) {
                        TicketInfoRow(label: "공연 일시", value: ticket.startDateFormatted)
                        TicketInfoRow(label: "예매자 명", value: ticket.buyerName)
                        TicketInfoRow(label: "생년월일", value: ticket.birthDateFormatted)
                        TicketInfoRow(label: "티켓 번호", value: ticket.ticketNumber)
                        TicketInfoRow(label: "좌석 번호", value: ticket.seatNumber)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 50)
                    .padding(.top, 20)

                    if let qr = ticket.qrCodeUrl, let url = URL(string: qr) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 260, height: 260)
                                .padding(.top, 12)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 260, height: 260)
                                .padding(.top, 12)
                        }
                    }

                    Spacer()

                    VStack(spacing: 16) {
                        CircleButton(title: "포토카드 보기") {
                            showPhotoCard = true
                        }

                        CircleButton(title: "NFT 티켓 보러가기") {
                            if let url = URL(string: ticket.nftUrl) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    .padding(.bottom, 50)
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
            } else {
                ProgressView()
            }
        }
        .task {
            await vm.fetch()
        }
        .fullScreenCover(isPresented: $showPhotoCard) {
            PhotoCardDetailView(ticketId: vm.ticket?.ticketId ?? 0)
        }
    }
}

struct TicketInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .foregroundColor(.black)
                .font(.system(size: 14, weight: .medium))
                .frame(width: 80, alignment: .leading) // ← 고정된 너비로 정렬 기준 맞춤
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .multilineTextAlignment(.leading)
        }
    }
}


