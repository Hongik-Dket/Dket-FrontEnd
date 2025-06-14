//
//  TicketDetailDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 5/4/25.
//

struct TicketDetailDTO: Decodable {
    let title:        String
    let userName:     String
    let userBirth:    String
    let ticketNumber: String
    let seat:         String
    let qrCodeUrl:    String?

    var domain: TicketDetail {
        .init(
            title: title,
            userName: userName,
            userBirth: userBirth,
            ticketNumber: ticketNumber,
            seat: seat,
            qrCodeUrl: qrCodeUrl
        )
    }
}
