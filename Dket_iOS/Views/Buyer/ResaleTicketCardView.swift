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
    let basePrice: Int = 180000  
    
    var priceRatioText: String {
        guard ticket.status == .available else { return "" }
        let ratio = Double(ticket.price) / Double(basePrice) * 100
        return String(format: "(%.0f%%)", ratio)
    }
    
    var statusColor: Color {
        switch ticket.status {
        case .available: return Color.dketBlue
        case .reserved: return .gray
        case .sold: return .red.opacity(0.6)
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: ticket.photoCardUrl) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 80, height: 100)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(statusColor, lineWidth: 2))
            
            VStack(alignment: .leading, spacing: 6) {
                Text("좌석번호 \(ticket.seatCode)")
                    .font(.headline)
                Text("\(ticket.price.formatted()) 원 \(priceRatioText)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(ticket.status.rawValue)
                    .font(.caption)
                    .padding(4)
                    .background(statusColor.opacity(0.2))
                    .cornerRadius(5)
            }
            Spacer()
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}
