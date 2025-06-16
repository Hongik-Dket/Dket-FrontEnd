//
//  OrganizerHomeViewModel.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/27/25.
//

import Foundation
import Combine

@MainActor
final class OrganizerHomeViewModel: ObservableObject {
    @Published var state: LoadingState = .idle
    @Published var home: HomeBundle?
    
    private let service: OrganizerHomeServicing
    init(service: OrganizerHomeServicing = OrganizerHomeService()) {
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
        print("🔄 개최자 홈 ViewModel 새로고침")
        await onAppear()
    }
}

enum LoadingState {
    case idle, loading, loaded
    case failed(Error)
}
