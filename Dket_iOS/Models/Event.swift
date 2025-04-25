import Foundation

struct Event: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let location: String
    let dateRange: String
    let bannerImageName: String   // 배너 이미지 파일명
    let state: EventState
    
    let enrollmentStart: String    
    let enrollmentEnd:   String
}

enum EventState {
    case preEnrollment    // 응모 전
    case enrolling   // 응모 중 (D-N)
    case enrollmentClosed // 응모 마감
    case ticketed         // 예매 완료
    case inProgress       // 공연 중
    case finished         // 공연 종료
    
    var label: String {
        switch self {
        case .preEnrollment:
          return "응모 전"
        case .enrolling:
          return "응모 중"
        case .enrollmentClosed:
          return "응모 마감"
        case .ticketed:
          return "예매 완료"
        case .inProgress:
          return "공연 중"
        case .finished:
          return "공연 종료"
        }
      }
}
