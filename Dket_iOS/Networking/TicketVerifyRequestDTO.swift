//
//  TicketVerifyRequestDTO.swift
//  Dket_iOS
//
//  Created by M-136 on 11/17/25.
//


// MARK: - Request
struct TicketVerifyRequestDTO: Encodable {
    let proofId: String
}

// MARK: - Response
struct TicketVerifyResponseDTO: Decodable {
    let identityType: String
    let ticketId: Int64
}