//
//  PhotoCardListViewModel.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

import Foundation

@MainActor
final class PhotoCardListViewModel: ObservableObject {
    @Published var cards: [PhotoCardItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: PhotoCardServicing

    init(service: PhotoCardServicing = PhotoCardService()) {
        self.service = service
    }

    func fetchCards() async {
        isLoading = true
        do {
            cards = try await service.fetchPhotoCardList()
        } catch {
            errorMessage = "포토카드를 불러오지 못했습니다."
        }
        isLoading = false
    }
}
