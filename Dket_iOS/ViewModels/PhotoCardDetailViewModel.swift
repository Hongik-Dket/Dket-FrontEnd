//
//  PhotoCardDetailViewModel.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/17/25.
//

import Foundation

@MainActor
final class PhotoCardDetailViewModel: ObservableObject {
    @Published var photoCard: PhotoCardDetail?

    private let ticketId: Int64
    private let service: PhotoCardServicing

    init(ticketId: Int64, service: PhotoCardServicing = PhotoCardService()) {
        self.ticketId = ticketId
        self.service = service
    }

    func fetch() async {
        do {
            let result = try await service.fetchPhotoCard(ticketId: ticketId)
            self.photoCard = result
        } catch {
            print("❌ 포토카드 조회 실패: \(error)")
        }
    }
}
