//
//  WalletInfoDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 8/20/25.
//

import SwiftUI

struct WalletInfoDTO: Decodable {
    let walletAddress: String
    let balance: Double
}

struct WalletInfo {
    let walletAddress: String
    let balance: Double
}

extension WalletInfoDTO {
    func toDomain() -> WalletInfo {
        .init(walletAddress: walletAddress, balance: balance)
    }
}
