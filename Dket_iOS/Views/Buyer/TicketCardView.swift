//
//  TicketCardView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

import SwiftUI

struct TicketCardView: View {
    let ticket: TicketListItem

    var body: some View {
        ZStack {
            if ticket.entered {
                HStack(spacing: 0) {
                    Image("AfterEnterTicket")
                        .resizable()
                        .frame(width: 300, height: 130)
                    Image("CuttedTicket")
                        .resizable()
                        .frame(width: 60, height: 120)
                }
            } else {
                Image("BeforeEnterTicket")
                    .resizable()
                    .frame(height: 130)
                    .padding(.horizontal, 20)
            }

            HStack(spacing: 16) {
                if let urlString = ticket.imageUrl,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 80, height: 100)
                    .padding(.leading, 32)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 100)
                        .padding(.leading, 32)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(ticket.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)

                    Text(ticket.location)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)

                    Text(ticket.dateFormatted)
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }

                Spacer()
            }
            .frame(height: 120)
        }
    }
}
