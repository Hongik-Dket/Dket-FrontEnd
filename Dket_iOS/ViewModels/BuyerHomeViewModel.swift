//
//  BuyerHomeViewModel.swift
//  Dket_iOS
//
//  Created by 이지우 on 5/27/25.
//

import Combine
import Foundation

@MainActor
final class BuyerHomeViewModel: ObservableObject {
    @Published var state: LoadingState = .idle
    @Published var home: BuyerHomeBundle?

    private let service: BuyerHomeServicing
    
    init(service: BuyerHomeServicing = BuyerHomeService()) {
        self.service = service
    }

    func onAppear() {
        Task { await load() }
    }

    private func load() async {
        state = .loading
        do {
            home = try await service.fetchHome()
            state = .loaded
        } catch {
            state = .failed(error)
        }
    }
    
    func refresh() async {
        print("🔄 구매자 홈 ViewModel 새로고침")
        await onAppear()
    }
}
