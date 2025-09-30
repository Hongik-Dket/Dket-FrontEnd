//
//  ResaleView.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import SwiftUI

struct ResaleView: View {
    let ticket: TicketDetail
    
    @State private var resalePrice: String = ""
    @State private var showSuccessAlert: Bool = false
    
    var ticketPrice: Int { ticket.price }
    var maxPrice: Int { Int(Double(ticketPrice) * 1.2) }
    
    var resalePriceInt: Int? { Int(resalePrice) }
    
    var isPriceValid: Bool {
        guard let resale = resalePriceInt else { return false }
        return resale >= ticketPrice && resale <= maxPrice
    }
    
    var contribution: Int {
        guard let resale = resalePriceInt else { return 0 }
        return max(0, resale - ticketPrice) / 10
    }
    
    var finalRevenue: Int {
        guard let resale = resalePriceInt else { return ticketPrice }
        return resale - contribution
    }
    
    var body: some View {
        ZStack{
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - Title
                    HStack {
                        Text("판매")
                            .font(.title2.bold())
                            .padding(.leading)
                        Spacer()
                    }
                    
                    // MARK: - 티켓 정보
                    GroupBox(label: Text("티켓 정보").font(.headline)) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                TextRow(title: "공연명", value: ticket.concertTitle)
                                TextRow(title: "공연 일시", value: ticket.startDateFormatted)
                                TextRow(title: "예매자 명", value: ticket.buyerName)
                                TextRow(title: "생년월일", value: ticket.birthDateFormatted)
                                TextRow(title: "티켓 번호", value: ticket.ticketNumber)
                                TextRow(title: "좌석 번호", value: ticket.seatNumber)
                            }
                            Spacer()
                            AsyncImage(url: URL(string: ticket.photoCardUrl)) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                            .frame(width: 90, height: 110)
                            .clipped()
                            .cornerRadius(8)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // MARK: - 판매 정보
                    GroupBox(label: Text("판매 정보").font(.headline)) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("티켓 정가")
                                Spacer()
                                Text("\(ticketPrice.formatted()) 원")
                            }
                            .font(.subheadline)
                            
                            HStack {
                                Text("판매가")
                                Spacer()
                                TextField("판매가 입력", text: $resalePrice)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 100)
                                    .textFieldStyle(.roundedBorder)
                                Text("원")
                            }
                            .font(.subheadline)
                            
                            HStack {
                                Text("공연 기여금")
                                Spacer()
                                Text("-\(contribution.formatted()) 원")
                            }
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            
                            Divider()
                            
                            HStack {
                                Text("최종 수익")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(finalRevenue.formatted()) 원")
                                    .foregroundColor(.dketBlue)
                                    .fontWeight(.bold)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // MARK: - 판매 규정
                    GroupBox(label: Text("판매 규정").font(.headline)) {
                        VStack(alignment: .leading, spacing: 4) {
                            
                            
                            Text("• 판매가는 티켓 정가의 최대 120%까지 설정할 수 있습니다.")
                            Text("• 공연 기여금은 판매가에서 티켓 정가를 뺀 금액의 10%이며, 이는 공연 개최자에게 돌아갑니다.")
                            Text("• 위 규정은 입장 마감 전까지 적용됩니다.")
                            Text("• 입장 마감 이후에는 가격 상한 제한이 없으며, 공연 기여금은 판매가의 10%로 책정됩니다.")
                        }
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.vertical, 8)
                    }
                    
                    // MARK: - 판매하기 버튼
                    CircleButton(
                        title: "판매하기",
                        action: {
                            showSuccessAlert = true
                        },
                        isDisabled: !isPriceValid
                    )
                    .padding(.top)
                }
                .padding()
            }
            
            if showSuccessAlert {
                ResaleSuccessAlert(
                    onConfirm: {
                        // ✅ 실제 판매 API 호출 로직 삽입
                        print("판매 확정: \(resalePriceInt ?? 0)원에 판매")
                        
                        // TODO: API 호출 -> 성공 시 뷰 닫기 또는 알림
                        showSuccessAlert = false
                    },
                    onClose: {
                        showSuccessAlert = false
                    }
                )
                .transition(.opacity)
                .animation(.easeInOut, value: showSuccessAlert)
            }
        }
    }
}


private struct TextRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundColor(.gray)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

extension Int {
    func formattedWithSeparator() -> String {
        NumberFormatter.localizedString(from: NSNumber(value: self), number: .decimal)
    }
}

struct ResaleView_Previews: PreviewProvider {
    static var previews: some View {
        ResaleView(
            ticket: TicketDetail(
                ticketId: 123,
                concertTitle: "공연이름~~~",
                concertDateTime: ISO8601DateFormatter().date(from: "2025-03-10T18:00:00") ?? Date(),
                buyerName: "여희주",
                birth: ISO8601DateFormatter().date(from: "2003-02-25T00:00:00") ?? Date(),
                ticketNumber: "T152670849345203",
                seatNumber: "39",
                qrCodeUrl: "",
                photoCardId: 1,
                nftUrl: "",
                entered: false,
                photoCardUrl: "https://via.placeholder.com/100", // 이미지 URL 대체
                price: 189000
            )
        )
    }
}
