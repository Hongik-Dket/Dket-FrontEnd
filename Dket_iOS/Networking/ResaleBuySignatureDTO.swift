//
//  ResaleBuySignatureDTO.swift
//  Dket_iOS
//
//  Created by M-136 on 11/7/25.
//

import Foundation

struct ResalePurchaseDTO: Decodable {
    let tokenId: Int64
    let expireAt: Int64
    let signature: String
}

extension ResalePurchaseDTO {
    var domain: ResalePurchase {
        ResalePurchase(
            tokenId: tokenId,
            expireAt: expireAt,
            signature: signature
        )
    }
}


