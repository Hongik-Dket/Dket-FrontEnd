//
//  ResaleTicketCardView.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import SwiftUI

import SwiftUI

struct ResaleTicketCardView: View {
    let ticket: ResaleTicket
    let basePrice: Int
    
    var pricePercent: Int? {
        guard basePrice > 0 else { return nil }
        return Int(Double(ticket.price) / Double(basePrice) * 100)
    }
    
    var statusColor: Color {
        switch ticket.status {
        case .available: return .green
        case .reserved:  return .orange
        case .sold:      return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: ticket.photoCardUrl) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 70, height: 90)
            .cornerRadius(8)
            .clipped()
            
            VStack(alignment: .leading, spacing: 6) {
                Text("좌석 \(ticket.seatCode)")
                    .font(.headline)
                HStack {
                    Text("\(ticket.price.formatted())원")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    if let percent = pricePercent, ticket.status != .sold {
                        Text("(\(percent)%)")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                
                Text(ticket.status == .available ? "거래 가능" :
                     ticket.status == .reserved ? "거래 진행 중" : "판매 완료")
                .font(.caption)
                .foregroundColor(statusColor)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
