//
//  WalletAddressDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/12/25.
//

struct WalletAddressRequest: Encodable {
    let walletAddress: String
    
    enum CodingKeys: String, CodingKey {
        case walletAddress // ✅ camelCase로 그대로 유지
    }
}

// Response
struct MetaMaskDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case isSuccess = "success"
        case code, message
    }
}
