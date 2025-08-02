//
//  TicketCardView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

import SwiftUI

struct TicketCardView: View {
    let ticket: MyTicket

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(ticket.entered ? "EnteredTicket" : "BeforeEnterTicket")
                .resizable()
                .frame(width: 350, height: 150)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 12) {
                    if let url = URL(string: ticket.posterUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(width: 97, height: 129)
                        .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 97, height: 129)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(ticket.concertTitle)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)

                        Text(ticket.location)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)

                        Text("\(ticket.sessionDateFormatted) \(ticket.startTimeFormatted)")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }

                    Spacer()
                }
                Spacer()
            }
            .padding(.top, 12)
            .padding(.leading, 16)
            .padding(.trailing, 16)
        }
        .frame(width: 350, height: 150)
    }
}
