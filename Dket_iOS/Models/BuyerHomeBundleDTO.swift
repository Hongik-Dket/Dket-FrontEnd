//
//  BuyerHomeBundleDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/2/25.
//

struct BuyerHomeBundleDTO: Decodable {
    let popularEvents:   [EventDTO]
    let appliedEvents:   [EventDTO]
    let purchasedEvents: [EventDTO]
    let entireEvents: [EventDTO]
}

extension BuyerHomeBundleDTO {
    var domain: BuyerHomeBundle {
        BuyerHomeBundle(
            popular:   popularEvents.map { $0.domain },
            applied:   appliedEvents.map { $0.domain },
            purchased: purchasedEvents.map { $0.domain },
            entire:    entireEvents.map { $0.domain }
        )
    }
}

struct BuyerHomeBundle {
    let popular:   [Event]
    let applied:   [Event]
    let purchased: [Event]
    let entire:    [Event]
}

