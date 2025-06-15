//
//  TicketListView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

import SwiftUI

struct TicketListView: View {
    let tickets: [TicketListItem]
    var onBack: () -> Void = {}
    var onMenu: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            TicketListHeaderView(title: "MY 티켓", onBack: onBack, onMenu: onMenu)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(tickets) { ticket in
                        TicketCardView(ticket: ticket)
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
    }
}

struct TicketListView_Previews: PreviewProvider {
    static var previews: some View {
        TicketListView(tickets: [
            TicketListItem(ticketId: 1, title: "뮤지컬 고흐", location: "홍대 극장", dateFormatted: "2025.03.20 18:00", imageUrl: nil, entered: false),
            TicketListItem(ticketId: 2, title: "재즈 나이트", location: "세종문화회관", dateFormatted: "2025.04.01 19:30", imageUrl: nil, entered: true),
            TicketListItem(ticketId: 3, title: "페스티벌 2025", location: "서울 올림픽공원", dateFormatted: "2025.06.05 17:00", imageUrl: nil, entered: false)
        ])
    }
}
