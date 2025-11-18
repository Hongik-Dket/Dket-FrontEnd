//
//  BuyerSearchViewModel.swift
//  Dket_iOS
//
//  Created by M-136 on 11/11/25.
//

import Foundation
import SwiftUI

@MainActor
final class BuyerSearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var results: [ConcertSearchCardDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let service: BuyerSearchServicing

    init(service: BuyerSearchServicing = BuyerSearchService()) {
        self.service = service
    }

    func search() async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let concerts = try await service.searchConcerts(keyword: query)
            results = concerts
        } catch {
            errorMessage = error.localizedDescription
            results = []
        }

        isLoading = false
    }
}
