//
//  MetaMaskLoginResponse.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/17/25.
//

struct MetaMaskLoginRequestDTO: Encodable {
    let walletAddress: String
}

struct MetaMaskLoginResponse: Codable {
    let token: String
}

struct MetaMaskLoginResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: MetaMaskLoginResult?
}

struct MetaMaskLoginResult: Decodable {
    let token: String
}
