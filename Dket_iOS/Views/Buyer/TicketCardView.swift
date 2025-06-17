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
        ZStack {
            if ticket.entered {
                HStack(spacing: 0) {
                    Image("AfterEnterTicket")
                        .resizable()
                        .frame(width: 350, height: 150)
                    Image("CuttedTicket")
                        .resizable()
                        .frame(width: 60, height: 150)
                }
            } else {
                Image("BeforeEnterTicket")
                    .resizable()
                    .frame(height: 150)
                    .padding(.horizontal, 20)
            }
            
            HStack(spacing: 16) {
                if let url = URL(string: ticket.posterUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 97, height: 129)
                    .clipped()
                    .padding(.leading, 32)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 97, height: 129)
                        .padding(.leading, 32)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(ticket.eventTitle)
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
            .frame(height: 120)
        }
    }
}
