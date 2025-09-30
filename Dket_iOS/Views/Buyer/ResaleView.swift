//
//  ResaleView.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import SwiftUI

struct ResaleView: View {
    let ticket: TicketDetail
    
    @Environment(\.dismiss) private var dismiss
    @State private var resalePriceText: String = ""
    
    // 정가
    private var ticketPrice: Int { ticket.price }
    // 입력받은 판매가
    private var resalePrice: Int {
        Int(resalePriceText) ?? 0
    }
    // 공연 기여금
    private var concertFee: Int {
        max(0, resalePrice - ticketPrice) / 10
    }
    // 최종 수익
    private var finalRevenue: Int {
        resalePrice - concertFee
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: 상단 바
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Text("판매")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "line.3.horizontal")
                        .font(.title3)
                        .foregroundColor(.black)
                }
                .padding(.horizontal)
                .padding(.top, 30)
                
                // MARK: 티켓 정보
                GroupBox(label: Text("티켓 정보").bold()) {
                    VStack(alignment: .leading, spacing: 8) {
                        ResaleInfoRow(label: "공연명", value: ticket.concertTitle)
                        ResaleInfoRow(label: "공연 일시", value: ticket.startDateFormatted)
                        ResaleInfoRow(label: "예매자 명", value: ticket.buyerName)
                        ResaleInfoRow(label: "생년월일", value: ticket.birthDateFormatted)
                        ResaleInfoRow(label: "티켓 번호", value: ticket.ticketNumber)
                        ResaleInfoRow(label: "좌석 번호", value: ticket.seatNumber)
                    }
                    .padding()
                }
                .padding(.horizontal)
                
                // MARK: 판매 정보
                GroupBox(label: Text("판매 정보").bold()) {
                    VStack(alignment: .leading, spacing: 16) {
                        ResaleInfoRow(label: "티켓 정가", value: "\(ticketPrice.formattedWithSeparator()) 원")
                        
                        HStack {
                            Text("판매가")
                                .frame(width: 80, alignment: .leading)
                            TextField("판매가 입력", text: $resalePriceText)
                                .keyboardType(.numberPad)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(6)
                        }
                        
                        ResaleInfoRow(label: "공연 기여금", value: "-\(concertFee.formattedWithSeparator()) 원")
                        ResaleInfoRow(label: "최종 수익", value: "\(finalRevenue.formattedWithSeparator()) 원", color: .blue)
                    }
                    .padding()
                }
                .padding(.horizontal)
                
                // MARK: 판매 규정
                VStack(alignment: .leading, spacing: 4) {
                    Text("판매 규정")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    Text("• 판매가는 티켓 정가의 최대 120%까지 설정할 수 있습니다.")
                    Text("• 공연 기여금은 판매가에서 티켓 정가를 뺀 금액의 10%이며, 이는 공연 개최자에게 돌아갑니다.")
                    Text("• 위 규정은 입장 마감 전까지 적용됩니다.")
                    Text("• 입장 마감 이후에는 가격 상한 제한이 없으며, 공연 기여금은 판매가의 10%로 책정됩니다.")
                }
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .padding()
                
                // MARK: 판매 버튼
                Button(action: {
                    // TODO: 판매 요청 API 호출
                    print("판매하기 클릭: \(resalePrice)원")
                }) {
                    Text("판매하기")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(resalePrice > 0 ? Color.dketBlue : Color.gray)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(resalePrice == 0)
            }
        }
    }
}

struct ResaleInfoRow: View {
    let label: String
    let value: String
    var color: Color = .black
    
    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.medium)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .foregroundColor(color)
        }
    }
}

extension Int {
    func formattedWithSeparator() -> String {
        NumberFormatter.localizedString(from: NSNumber(value: self), number: .decimal)
    }
}
