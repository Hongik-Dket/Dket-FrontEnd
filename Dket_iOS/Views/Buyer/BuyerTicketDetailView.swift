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
    @State private var showResaleView = false
    @State private var showEnterView = false
    @State private var selectedTicket: TicketDetail? = nil
    @State private var showPhotoFullScreen = false
    
    init(ticketId: Int64) {
        print("BuyerTicketDetailView INIT with ticketId: \(ticketId)")
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
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            dismiss()
                        }
                    }) {
                        Text(ticket.concertTitle)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color.dketBlue)
                            .underline()
                            .padding(.top, 120)
                    }
                    .buttonStyle(.plain)
                    
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
                    
                    if let url = URL(string: ticket.photoCardUrl) {
                        VStack(spacing: 16) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 260, height: 260)
                                    .cornerRadius(8)
                                    .shadow(radius: 4)
                                    .padding(.top, 12)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 260, height: 260)
                                    .padding(.top, 12)
                            }
                            .onTapGesture {
                                showPhotoFullScreen = true
                            }
                            
                            if let nftUrl = URL(string: ticket.nftUrl) {
                                Button(action: {
                                    UIApplication.shared.open(nftUrl)
                                }) {
                                    Text("NFT 확인하기 →")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color.dketBlue)
                                        .underline()
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 25)
                            }
                        }
                        .fullScreenCover(isPresented: $showPhotoFullScreen) {
                            FullScreenPhotoView(imageUrl: ticket.photoCardUrl) {
                                showPhotoFullScreen = false
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        CircleButton(title: "판매하기") {
                            selectedTicket = ticket
                            showResaleView = true
                        }
                        .disabled(!isSellButtonEnabled)
                        .opacity(isSellButtonEnabled ? 1 : 0.4)
                        
                        CircleButton(title: "입장하기") {
                            selectedTicket = ticket
                            showEnterView = true
                        }
                        .disabled(!isEnterButtonEnabled)
                        .opacity(isEnterButtonEnabled ? 1 : 0.4)
                    }
                    .padding(.bottom, 50)
                }
                
                // 상단 닫기(X) 버튼
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
        .fullScreenCover(isPresented: $showResaleView) {
            ResaleRegisterView(ticket: selectedTicket ?? vm.ticket!)
        }
        .fullScreenCover(isPresented: $showEnterView) {
            if let ticket = selectedTicket {
                BuyerEnterCodeView(ticketId: ticket.ticketId)
            }
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
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .multilineTextAlignment(.leading)
        }
    }
}

struct FullScreenPhotoView: View {
    let imageUrl: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } placeholder: {
                ProgressView()
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding(.top, 40)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
        }
    }
}

extension BuyerTicketDetailView {
    private var isConcertToday: Bool {
        guard let ticket = vm.ticket else { return false }
        let calendar = Calendar.current
        return calendar.isDateInToday(ticket.concertDateTime)
    }
    
    private var isSellButtonEnabled: Bool {
        guard let ticket = vm.ticket else { return false }
        // ① 아직 리세일 등록 안됨
        if !ticket.isResaleListed { return true }
        // ② 이미 리세일 중인데 공연 전 → 비활성화
        if ticket.isResaleListed && !isConcertToday { return false }
        // ③ 리세일 중인데 공연 당일 → 비활성화
        if ticket.isResaleListed && isConcertToday { return false }
        return false
    }
    
    private var isEnterButtonEnabled: Bool {
        guard let ticket = vm.ticket else { return false }
        // 리세일 중이고 공연 당일에만 활성화
        return ticket.isResaleListed && isConcertToday
    }
}


struct BuyerTicketDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = BuyerTicketDetailViewModel(ticketId: 100)
        Task { @MainActor in
            vm.ticket = TicketDetail(
                ticketId: 1,
                concertTitle: "홍익대 축제 공연",
                concertDateTime: Date().addingTimeInterval(3600 * 5),
                buyerName: "여희주",
                birth: DateFormatter.yyyyMMdd.date(from: "2003-02-25") ?? Date(),
                ticketNumber: "T152670849345203",
                seatNumber: "A-39",
                nftUrl: "https://opensea.io/assets/0x123.../1",
                isEntered: false,
                photoCardUrl: "https://i.imgur.com/Qb0k5.jpg",
                price: 100000,
                isResaleListed: false
            )
        }
        
        return BuyerTicketDetailView(ticketId: 100)
            .previewDisplayName("🎫 Buyer Ticket Detail Preview")
    }
}


