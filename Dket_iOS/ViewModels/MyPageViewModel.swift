//
//  MyPageViewModel.swift
//  Dket_iOS
//
//  Created by 이지우 on 8/20/25.
//

import Foundation

@MainActor
final class MypageViewModel: ObservableObject {
    @Published var walletInfo: WalletInfo? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let service: MypageServicing

    init(service: MypageServicing = MypageService()) {
        self.service = service
    }

    func fetchWalletInfo() {
        Task {
            do {
                isLoading = true
                walletInfo = try await service.fetchWalletInfo()
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
