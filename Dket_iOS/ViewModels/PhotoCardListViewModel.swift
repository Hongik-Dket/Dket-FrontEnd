//
//  PhotoCardListViewModel.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

import Foundation

@MainActor
final class PhotoCardListViewModel: ObservableObject {
    @Published var photoCards: [PhotoCardItem] = []

    func fetchPhotoCards() {
        // 실제 네트워크 요청은 생략하고, 미리보기용 더미 데이터 삽입
        self.photoCards = [
            PhotoCardItem(photoCardId: 101, imageUrl: "https://ipfs.io/ipfs/Qm123abc/photo1.png"),
            PhotoCardItem(photoCardId: 102, imageUrl: "https://ipfs.io/ipfs/Qm456def/photo2.png"),
            PhotoCardItem(photoCardId: 103, imageUrl: "https://ipfs.io/ipfs/Qm789ghi/photo3.png")
        ]
    }
}

extension PhotoCardListViewModel {
    static var preview: PhotoCardListViewModel {
        let vm = PhotoCardListViewModel()
        vm.photoCards = [
            PhotoCardItem(photoCardId: 1, imageUrl: "https://ipfs.io/ipfs/Qm123/photo1.png"),
            PhotoCardItem(photoCardId: 2, imageUrl: "https://ipfs.io/ipfs/Qm456/photo2.png"),
            PhotoCardItem(photoCardId: 3, imageUrl: "https://ipfs.io/ipfs/Qm789/photo3.png")
        ]
        return vm
    }
}
