//
//  EventSetupViewModel.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/30/25.
//

import SwiftUI

@MainActor
final class ConcertSetupViewModel: ObservableObject {
    @Published var title          = ""
    @Published var ageFilter: AgeLimit?
    @Published var location       = ""
    @Published var description    = ""
    
    @Published var startDate      = Date()
    @Published var endDate        = Date()
    @Published var startTimeText  = "18:00"
    @Published var endTimeText    = "20:00"
    
    @Published var applyStart     = Date()
    @Published var applyEnd       = Date()
    
    @Published var priceKrw:   Int = 0
    @Published var capacity:   Int = 0
    @Published var ageLimit:   AgeLimit = .all
    
    @Published var bannerImageData:    Data?
    @Published var posterImageData:    Data?
    @Published var photocardImageDatas: [Data] = []
    
    @Published var state: LoadingState = .idle
    @Published var alertMessage: String?
    @Published var isShowingAlert = false
    
    private let api = APIClient.shared
    
    // MARK: - 유효성 검증
    private func validate() throws {
        guard !title.isEmpty,
              !location.isEmpty,
              !description.isEmpty else {
            throw ValidationError("모든 텍스트 항목을 입력해주세요.")
        }
        
        guard startDate <= endDate,
              applyStart <= applyEnd else {
            throw ValidationError("날짜/시간 순서를 다시 확인해주세요.")
        }
        
        let timeRegex = #"^\d{2}:\d{2}$"#
        guard startTimeText.range(of: timeRegex, options: .regularExpression) != nil,
              endTimeText.range(of: timeRegex,   options: .regularExpression) != nil else {
            throw ValidationError("시작/종료 시각은 HH:mm 형식으로 입력하세요.")
        }
        
        guard let _ = bannerImageData,
              let _ = posterImageData else {
            throw ValidationError("배너·포스터 이미지를 모두 선택해주세요.")
        }
        
        let now = Date()
        if applyStart < now {
            throw ValidationError("응모 시작 시간은 현재 시각보다 이후여야 합니다.")
        }
        if applyEnd <= applyStart {
            throw ValidationError("응모 종료일은 응모 시작일보다 이후여야 합니다.")
        }
        let paymentDeadlineEnd = Calendar.current.date(byAdding: .day, value: 2, to: applyEnd) ?? applyEnd
        let concertStartAtMidnight = Calendar.current.startOfDay(for: startDate)
        if paymentDeadlineEnd > concertStartAtMidnight {
            throw ValidationError("응모 종료 후 2일 이내에 공연이 시작되어야 합니다.")
        }
        if endDate < startDate {
            throw ValidationError("공연 종료일은 공연 시작일보다 이후여야 합니다.")
        }
    }
    
    // MARK: - 업로드
    func createConcert() {
        print("▶︎ startTimeText = [\(startTimeText)], endTimeText = [\(endTimeText)]")
        Task {
            do {
                try validate()
                state = .loading
                
                // DTO 구성 (날짜 포맷은 DTO 내부 encode(to:)에서 처리)
                let dto = ConcertCreateRequestDTO(
                    title:       title,
                    location:    location,
                    description: description,
                    startDate:   startDate,
                    endDate:     endDate,
                    startTime:   "\(startTimeText):00",   // “HH:mm:ss”
                    endTime:     "\(endTimeText):00",
                    priceKrw:    priceKrw,
                    capacity:    capacity,
                    applyStart:  applyStart,
                    applyEnd:    applyEnd,
                    ageLimit:    ageLimit
                )
                
                // 실제 업로드
                let response: APIResponse<ConcertCreateResponseDTO> = try await api.upload(
                    .organizerCreateConcert,
                    json: dto,
                    banner: bannerImageData!,
                    poster: posterImageData!,
                    photocardList: photocardImageDatas
                )
                
                NotificationCenter.default.post(name: .concertCreated, object: nil)
                state = .loaded        
                
            } catch let e as ValidationError {
                state = .failed(e)
                alertMessage = e.localizedDescription
                isShowingAlert = true
            } catch {
                state = .failed(error)
                alertMessage = error.localizedDescription
                isShowingAlert = true
            }
        }
    }
}

private struct ValidationError: LocalizedError {
    let message: String
    init(_ msg: String) { message = msg }
    var errorDescription: String? { message }
}

struct EmptyResultDTO: Decodable {}


