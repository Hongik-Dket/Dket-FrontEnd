//
//  ResaleRegisterResponseDTO.swift
//  Dket_iOS
//
//  Created by M-136 on 10/30/25.
//

import Foundation

struct ResaleRegisterResponseDTO: Decodable {
    let resaleId: Int64
    let tokenId: Int64
    let challengeId: String
    let challenge: String
}
