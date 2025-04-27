import Foundation

// Models/Event.swift  –  뷰가 직접 쓰는 순수 모델
struct Event: Identifiable, Equatable {
    let id: Int64
    let title: String
    let location: String
    let period: ClosedRange<Date>
    let bannerURL: URL
    let status: EventStatus?
    let applyPeriod: ClosedRange<Date>?
}

// 변환 메서드 (DTO → Domain)
extension Event {
    init(dto: EventResponse, dateFmt: DateFormatter) {
        self.id        = dto.eventId
        self.title     = dto.title
        self.location  = dto.location
        self.period    = dateFmt.date(from: dto.startDate)! ... dateFmt.date(from: dto.endDate)!
        self.bannerURL = URL(string: dto.bannerUrl)!
        self.status    = EventStatus(rawValue: dto.eventStatus ?? "")
        if let s = dto.applyStart, let e = dto.applyEnd {
            self.applyPeriod = dateFmt.date(from: s)! ... dateFmt.date(from: e)!
        } else {
            self.applyPeriod = nil
        }
    }
}

//struct Event: Identifiable, Hashable {
//    let id = UUID()
//    let name: String
//    let location: String
//    let dateRange: String
//    let bannerImageName: String   // 배너 이미지 파일명
//    let state: EventState
//    
//    let enrollmentStart: String    
//    let enrollmentEnd:   String
//}
//
//enum EventState {
//    case preEnrollment    // 응모 전
//    case enrolling   // 응모 중 (D-N)
//    case enrollmentClosed // 응모 마감
//    case ticketed         // 예매 완료
//    case inProgress       // 공연 중
//    case finished         // 공연 종료
//    
//    var label: String {
//        switch self {
//        case .preEnrollment:
//          return "응모 전"
//        case .enrolling:
//          return "응모 중"
//        case .enrollmentClosed:
//          return "응모 마감"
//        case .ticketed:
//          return "예매 완료"
//        case .inProgress:
//          return "공연 중"
//        case .finished:
//          return "공연 종료"
//        }
//      }
//}
