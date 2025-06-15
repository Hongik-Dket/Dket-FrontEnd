//
//  PriceWeiResponse.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

import BigInt

struct PriceWeiResult: Decodable {
    let sessionId: Int64
    let priceWei: UInt64
}
