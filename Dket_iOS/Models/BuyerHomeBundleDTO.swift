//
//  BuyerHomeBundleDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/2/25.
//

struct BuyerHomeBundleDTO: Decodable {
    let popularConcerts:   [ConcertDTO]
    let appliedConcerts:   [ConcertDTO]
    let purchasedConcerts: [ConcertDTO]
    let entireConcerts: [ConcertDTO]
}

extension BuyerHomeBundleDTO {
    var domain: BuyerHomeBundle {
        BuyerHomeBundle(
            popular:   popularConcerts.map { $0.domain },
            applied:   appliedConcerts.map { $0.domain },
            purchased: purchasedConcerts.map { $0.domain },
            entire:    entireConcerts.map { $0.domain }
        )
    }
}

struct BuyerHomeBundle {
    let popular:   [Concert]
    let applied:   [Concert]
    let purchased: [Concert]
    let entire:    [Concert]
}

