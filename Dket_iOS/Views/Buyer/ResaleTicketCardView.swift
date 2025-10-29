//
//  ResaleTicketCardView.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import SwiftUI

struct ResaleTicketCardView: View {
    let ticket: ResaleTicket

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 105, height: 140)
                .overlay {
                    if let url = ticket.photoCardURL {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(ticket.price.formatted()) 원 (+20%)")
                    .fontWeight(.bold)
                Text("좌석 번호: \(ticket.seatNumber)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(ticket.isAvailable ? "거래 가능" : "거래 진행 중")
                    .font(.subheadline)
                    .foregroundColor(ticket.isAvailable ? .dketBlue : .gray)
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
