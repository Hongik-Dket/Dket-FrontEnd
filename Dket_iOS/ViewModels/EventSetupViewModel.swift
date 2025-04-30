//
//  EventSetupViewModel.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/30/25.
//

import SwiftUI          // ⬅︎ Combine 없이 Swift Concurrency만 사용

@MainActor
final class EventSetupViewModel: ObservableObject {
    // ────────── View 바인딩용 입력값 ──────────
    @Published var title          = ""
    @Published var ageFilter: AgeLimit?
    @Published var location       = ""
    @Published var description    = ""
    
    // 날짜 / 시각(텍스트)  — DatePicker 두 개 + TextField 두 개 조합 예시
    @Published var startDate      = Date()            // DatePicker (yyyy-MM-dd)
    @Published var endDate        = Date()
    @Published var startTimeText  = "18:00"           // HH:mm
    @Published var endTimeText    = "20:00"
    
    // 응모 기간
    @Published var applyStart     = Date()            // DatePicker (yyyy-MM-dd HH:mm)
    @Published var applyEnd       = Date()
    
    @Published var price:      Int = 0
    @Published var capacity:   Int = 0
    @Published var ageLimit:   AgeLimit = .all        // 기본값
    
    // 이미지 – 뷰에서 UIImage/Data 로 주입
    @Published var bannerImageData:    Data?
    @Published var posterImageData:    Data?
    @Published var photocardImageData: Data?
    
    // 상태
    @Published var state: LoadingState = .idle
    @Published var alertMessage: String?              // 실패 알림용
    
    private let api = APIClient.shared
    
    // MARK: - 유효성 검증
    private func validate() throws {
        // ① 필수 텍스트
        guard !title.isEmpty,
              !location.isEmpty,
              !description.isEmpty else {
            throw ValidationError("모든 텍스트 항목을 입력해주세요.")
        }
        // ② 날짜 순서
        guard startDate <= endDate,
              applyStart <= applyEnd else {
            throw ValidationError("날짜/시간 순서를 다시 확인해주세요.")
        }
        // ③ 시각 포맷(HH:mm) – 간단 정규식 검사
        let timeRegex = #"^\d{2}:\d{2}$"#
        guard startTimeText.range(of: timeRegex, options: .regularExpression) != nil,
              endTimeText.range(of: timeRegex,   options: .regularExpression) != nil
        else {
            throw ValidationError("시작/종료 시각은 HH:mm 형식으로 입력하세요.")
        }
        // ④ 필수 이미지
        guard let _ = bannerImageData,
              let _ = posterImageData else {
            throw ValidationError("배너·포스터 이미지를 모두 선택해주세요.")
        }
    }
    
    // MARK: - 업로드
    func createEvent() {
        Task {
            do {
                try validate()
                state = .loading
                
                // DTO 구성 (날짜 포맷은 DTO 내부 encode(to:)에서 처리)
                let dto = EventCreateRequestDTO(
                    title:       title,
                    location:    location,
                    description: description,
                    startDate:   startDate,
                    endDate:     endDate,
                    startTime:   "\(startTimeText):00",   // “HH:mm:ss”
                    endTime:     "\(endTimeText):00",
                    price:       price,
                    capacity:    capacity,
                    applyStart:  applyStart,
                    applyEnd:    applyEnd,
                    ageLimit:    ageLimit
                )
                
                // 실제 업로드
                let _: APIResponse<EmptyResultDTO> = try await api.upload(
                    .organizerCreateEvent,           // Endpoint 에 새 케이스 추가 필요
                    json: dto,
                    banner: bannerImageData!,
                    poster: posterImageData!,
                    photocard: photocardImageData
                )
                
                state = .loaded        // 성공
            } catch let e as ValidationError {
                state = .failed(e)
                alertMessage = e.localizedDescription
            } catch {
                state = .failed(error)
                alertMessage = error.localizedDescription
            }
        }
    }
}

// 단순 Validation 오류용 타입
private struct ValidationError: LocalizedError {
    let message: String
    init(_ msg: String) { message = msg }
    var errorDescription: String? { message }
}

// 서버가 body 를 반환하지 않을 때 쓸 빈 DTO
struct EmptyResultDTO: Decodable {}
