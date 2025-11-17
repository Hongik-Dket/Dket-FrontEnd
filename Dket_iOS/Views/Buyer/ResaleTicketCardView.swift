//
//  ResaleTicketCardView.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import SwiftUI

struct ResaleTicketCardView: View {
    let ticket: ResaleTicket
    let basePrice: Int
    
    // MARK: - 가격 퍼센트 계산
    var pricePercent: Int? {
        guard basePrice > 0 else { return nil }
        return Int(round(Double(ticket.price) / Double(basePrice) * 100))
    }
    
    // MARK: - 상태별 색상
    var statusColor: Color {
        switch ticket.status {
        case .available: return Color.dketBlue
        case .reserved:  return .red
        case .sold:      return .gray
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // MARK: - 포토카드 썸네일
            AsyncImage(url: ticket.photoCardUrl) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.15)
            }
            .frame(width: 90, height: 110)
            .cornerRadius(10)
            .clipped()
            
            // MARK: - 정보 텍스트
            VStack(alignment: .leading, spacing: 6) {
                
                HStack(spacing: 4) {
                    Text("\(ticket.price.formatted()) 원")
                        .font(.system(size: 16, weight: .semibold))
                    
                    if let percent = pricePercent {
                        let diff = percent - 100
                        let sign = diff > 0 ? "+" : "" // 양수만 + 표시
                        Text("(\(sign)\(diff)%)")
                            .font(.system(size: 14))
                            .foregroundColor(diff > 0 ? .dketBlue : .red)
                    }
                }
                
                // 좌석 정보
                Text("좌석 번호: \(ticket.seatCode)")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                // 거래 상태
                Text(ticket.status == .available ? "거래 가능" :
                        ticket.status == .reserved ? "거래 진행 중" : "판매 완료")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(statusColor)
                .padding(.top, 2)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}
