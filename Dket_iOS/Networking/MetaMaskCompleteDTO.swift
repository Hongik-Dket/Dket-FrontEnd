//
//  MetaMaskCompleteDTO.swift
//  Dket_iOS
//
//  Created by M-136 on 11/3/25.
//

struct MetaMaskCompleteRequestDTO: Encodable {
    let walletAddress: String
}

struct MetaMaskCompleteResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
}
