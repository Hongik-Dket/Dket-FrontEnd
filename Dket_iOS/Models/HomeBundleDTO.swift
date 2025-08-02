//
//  HomeBundleDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/27/25.
//

struct HomeBundleDTO: Decodable {
    let todayConcerts:               [ConcertDTO]
    let recentlyClosedApplyConcerts: [ConcertDTO]
    let allConcerts:                 [ConcertDTO]
    let endedConcerts:               [ConcertDTO]
}

extension HomeBundleDTO {
    var domain: HomeBundle {
        HomeBundle(
            today:           todayConcerts.map { $0.domain },
            recentlyClosed:  recentlyClosedApplyConcerts.map { $0.domain },
            all:             allConcerts.map { $0.domain },
            ended:           endedConcerts.map { $0.domain })
    }
}

// ViewModel이 한꺼번에 보관하는 묶음
struct HomeBundle {
    let today:          [Concert]
    let recentlyClosed: [Concert]
    let all:            [Concert]
    let ended:          [Concert]
}
