import SwiftUI

struct EventDetailView: View {
    // MARK: – DI
    private let eventId: Int64
    @Environment(\.dismiss) private var dismiss
    
    // ① 스캐너 & 수동 입력 시트 플래그
    @State private var showScanner = false
    @State private var showTicketNumberEntry = false
    
    // MARK: – VM
    @StateObject private var vm: EventDetailViewModel
    
    // 티켓 검증 알럿 바인딩
    @State private var showVerifyAlert = false
    @State private var verifyTitle = ""
    @State private var verifyMessage = ""
    
    // 외부에서 eventId 만 넘기면 뷰-모델을 알아서 만들도록 편의 init 제공
    @MainActor
    init(eventId: Int64) {
        self.eventId = eventId
        _vm = StateObject(wrappedValue: EventDetailViewModel(eventId: eventId))
    }
    
    var body: some View {
        Group {
            switch vm.state {
            case .idle, .loading:
                ProgressView().task { vm.onAppear() }
            case .failed(let error):
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 32))
                        .foregroundStyle(.orange)
                    Text(error.localizedDescription)
                    Button("다시 시도") { vm.onAppear() }
                }
            case .loaded:
                if let detail = vm.detail { content(detail) }
            }
        }
        .navigationTitle("공연 상세")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
                .toolbar {                                  
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }
                }
        // ② QR 스캐너 풀스크린 커버
        .fullScreenCover(isPresented: $showScanner) {
            QRScannerContainerView(
                onScan: { code in
                    showScanner = false
                    vm.verifyTicket(with: code)
                },
                onManualTap: {
                    showTicketNumberEntry = true
                }
            )
        }
       
        // 검증 상태 변화 감지해서 Alert 띄우기
        .onChange(of: vm.verificationState) { state in
            switch state {
            case .idle, .verifying:
                break
            case .success(let message):
                verifyTitle = "입장 확인 완료"
                verifyMessage = message
                showVerifyAlert = true
            case .failure(let error):
                verifyTitle = "입장 확인 실패"
                verifyMessage = error
                showVerifyAlert = true
            }
        }
        .alert(verifyTitle, isPresented: $showVerifyAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(verifyMessage)
        }
    }
    
    @ViewBuilder
    func content(_ d: EventDetail) -> some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    PosterView(url: d.poster)
                    BasicInfoView(detail: d)
                    Divider()
                    
                    // ① 응모 전엔 회차 선택 자체를 보여주지 않고 D-day 텍스트만
                    if d.status == .applyNotOpened {
                        Text("응모 D-\(Date().daysUntil(d.applyPeriod.lowerBound))일")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    } else {
                        SessionPickerView(detail: d)
                        Divider()
                        // ②/③/④/⑤/⑥ 상태별 통계 섹션
                        SessionStatSection()
                    }
                    
                    Spacer(minLength: 80) // 플로팅 버튼 공간 확보
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            
            // ③ 공연 중인 당일에만 활성화되는 플로팅 버튼
            if let d = vm.detail, d.status == .inProgress {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showScanner = true }) {
                            Label("공연 입장 확인하기", systemImage: "ticket.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: 360, maxHeight: 48)
                        }
                        // 배경색을 isTodaySession 으로 분기
                        .background(
                            isTodaySession
                            ? Color(red: 22/255, green: 29/255, blue: 111/255)    // 활성화 시 진한 파랑
                            : Color.gray.opacity(0.5)                             // 비활성 시 반투명 회색
                        )
                        .cornerRadius(24)
                        .shadow(radius: 4)
                    }
                    .disabled(!isTodaySession)
                    .padding()
                }
            }
            
            if d.status == .ended {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                Image("EndedEvent")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .opacity(0.8)
            }
        }
        .environmentObject(vm)
    }
    
    private var isTodaySession: Bool {
        guard let s = vm.selectedSession else { return false }
        let today = Calendar.current.startOfDay(for: Date())
        let sessionDay = Calendar.current.startOfDay(for: s.date)
        return today == sessionDay
    }
}

// MARK: – Sub-views
private struct PosterView: View {
    let url: URL
    var body: some View {
        AsyncImage(url: url) { image in
            image.resizable().scaledToFit()
        } placeholder: {
            Rectangle().fill(.gray.opacity(0.3))
                .overlay { ProgressView() }
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct SessionPickerView: View {
    @EnvironmentObject private var vm: EventDetailViewModel
    let detail: EventDetail
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("공연 날짜").font(.headline)
            Picker("Session", selection: $vm.selectedSessionId) {
                ForEach(detail.sessionIds, id: \.self) { id in
                    SessionLabel(id: id)
                        .tag(id as Int64?)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    @ViewBuilder
    private func SessionLabel(id: Int64) -> some View {
        if let session = vm.sessionCache[id] {
            Text(DateFormatter.sessionDateFormatter.string(from: session.date))
        } else {
            Text("세션 \(id)")
        }
    }
}

private struct BasicInfoView: View {
    let detail: EventDetail
    
    // 공연 기간 텍스트
    private var periodText: String {
        let df = DateFormatter.yyyyDMMDdd     // ⬅︎ 기존 전역 포맷터 재활용
        return "\(df.string(from: detail.period.lowerBound))"
        + " ~ "
        + "\(df.string(from: detail.period.upperBound))"
    }
    
    // 응모 기간 텍스트
    private var applyPeriodText: String {
        let df = DateFormatter.yyyyDMMDdd
        return "\(df.string(from: detail.applyPeriod.lowerBound))"
        + " ~ "
        + "\(df.string(from: detail.applyPeriod.upperBound))"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 공연명
            Text(detail.title).font(.title2).bold()
            
            // 장소
            Text(detail.location)
                .font(.callout).foregroundStyle(.secondary)
            
            // 기간
            Text(periodText)
                .font(.system(size: 16))
            // 시간
            Text("\(detail.timeRange.start) – \(detail.timeRange.end)")
                .font(.subheadline)
            
            Text(detail.ageLimit.label)
                .font(.footnote)
            
            Divider().padding(.vertical, 4)
            
            // 응모 기간
            HStack {
                Text("응모 기간")
                Spacer()
                Text(applyPeriodText)
            }
            .font(.footnote)
            
            // 공연 상태
            HStack {
                Text("공연 상태")
                Spacer()
                Text(detail.status.label)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 22/255, green: 29/255, blue: 111/255))
            }
            .font(.footnote)
            
            // 관람 인원
            HStack {
                Text("관람 인원")
                Spacer()
                Text("\(detail.capacity)명")
            }
            .font(.footnote)
            
            HStack {
                Text("가격")
                Spacer()
                Text("\(detail.price.formatted()) 원")
            }
            .font(.footnote)
        }
    }
}

private struct SessionStatSection: View {
    @EnvironmentObject private var vm: EventDetailViewModel
    
    var body: some View {
        // detail 과 selectedSession 이 준비되어 있으면
        if let detail = vm.detail, let s = vm.selectedSession {
            VStack(alignment: .leading, spacing: 15) {
                // 회차 날짜
                Text(s.date.formatted(.dateTime.year().month().day()))
                    .font(.title3).bold()
                
                // 카운트 + 달성률
                Group {
                    let (title, count): (String, Int) = {
                        switch detail.status {
                        case .applyOpen:      return ("응모자 수",      s.applyCount)
                        case .applyClosed,
                                .ticketed:       return ("예매자 수",      s.paidCount ?? 0)
                        case .inProgress:     return ("입장 완료 수",    s.attendeeCount ?? 0)
                        case .ended:          return ("관람자 수",      s.attendeeCount ?? 0)
                        default:              return ("",               0)
                        }
                    }()
                    // 1) StatText: 카운트 뒤에 '명'
                    HStack {
                        Text(title)
                            .font(.caption)
                        Spacer()
                        Text("\(count)명")
                    }
                    
                    // 2) 달성률 레이블 + %
                    if detail.status != .applyNotOpened && detail.status != .ended {
                        // 달성률 계산
                        let percent = detail.capacity > 0
                        ? Double(count) / Double(detail.capacity)
                        : 0
                        HStack {
                            Text(detail.status == .applyOpen
                                 ? "응모 달성률"
                                 : "예매 달성률")
                            .font(.caption)
                            Spacer()
                            Text("\(Int(percent * 100))%")
                                .bold()
                                .font(.caption)
                        }
                        // 3) ProgressView
                        ProgressView(value: percent)
                            .progressViewStyle(.linear)
                    }
                }
                
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
        } else {
            ProgressView()
                .frame(maxWidth: .infinity)
        }
    }
    
    private struct StatText: View {
        let title: String
        let value: Int
        var body: some View {
            HStack {
                Text(title).font(.caption)
                Spacer()
                Text("\(value)").bold()
            }
        }
    }
}

extension Date {
    /// self부터 to까지 남은 일수를 계산합니다.
    func daysUntil(_ to: Date) -> Int {
        Calendar.current
            .dateComponents([.day], from: self, to: to)
            .day ?? 0
    }
}

//private extension EventDetailView {
//
//    /// 실제 디테일 콘텐츠
//    @ViewBuilder
//    func content(_ d: EventDetail) -> some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
//
//                // ───────── 포스터 ─────────
//                AsyncImage(url: d.poster) { image in
//                    image.resizable().scaledToFit()
//                } placeholder: {
//                    Rectangle().fill(.gray.opacity(0.3))
//                        .overlay { ProgressView() }
//                }
//                .frame(maxWidth: .infinity)
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//
//                // ───────── 기본 정보 ─────────
//                VStack(alignment: .leading, spacing: 6) {
//                    Text(d.title)
//                        .font(.title2).bold()
//                    Text(d.location)
//                        .font(.callout)
//                        .foregroundStyle(.secondary)
//
//                    Text("\(d.period.start.formatted(.dateTime.year().month().day()))"
//                         + " - "
//                         + "\(d.period.end.formatted(.dateTime.year().month().day()))")
//
//                    Text("\(d.timeRange.start) – \(d.timeRange.end)")
//                        .font(.subheadline)
//
//                    HStack {
//                        Text(d.ageLimit.label)       // AgeLimit 이미 label 프로퍼티 가지고 있음
//                        Spacer()
//                        Text("\(d.price.formatted()) 원")
//                    }
//                    .font(.footnote)
//                }
//
//                Divider()
//
//                // ───────── 회차 선택 – Picker ─────────
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("회차 선택")
//                        .font(.headline)
//
//                    Picker("Session", selection: $vm.selectedSessionId) {
//                        ForEach(d.sessionIds, id: \.self) { id in
//                            // 날짜를 보기 좋게 표시하기 위해 캐시된 세션 디테일 or id 로만
//                            if let session = vm.sessionCache[id] {
//                                Text(session.date.formatted(.dateTime.year().month().day()))
//                                    .tag(id as Int64?)
//                            } else {
//                                Text("세션 \(id)").tag(id as Int64?)
//                            }
//                        }
//                    }
//                    .pickerStyle(.segmented)
//                }
//
//                // ───────── 선택된 회차 정보 ─────────
//                if let s = vm.selectedSession {
//                    sessionInfoView(s)
//                } else {
//                    ProgressView()
//                        .frame(maxWidth: .infinity)
//                }
//
//                Spacer(minLength: 40)
//            }
//            .padding(.horizontal)
//            .padding(.vertical, 12)
//        }
//    }
//
//    /// 회차 별 통계 Section
//    @ViewBuilder
//    func sessionInfoView(_ s: SessionDetail) -> some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text(s.date.formatted(.dateTime.year().month().day()))
//                .font(.title3).bold()
//
//            HStack {
//                statBlock(title: "응모", value: s.applyCount)
//                Spacer()
//                statBlock(title: "예매", value: s.paidCount)
//                Spacer()
//                statBlock(title: "입장", value: s.attendeeCount)
//            }
//            .padding()
//            .background(.gray.opacity(0.1))
//            .clipShape(RoundedRectangle(cornerRadius: 8))
//        }
//    }
//
//    @ViewBuilder
//    func statBlock(title: String, value: Int?) -> some View {
//        VStack {
//            Text(title).font(.caption)
//            if let v = value {
//                Text("\(v)").bold()
//            } else {
//                Text("-").foregroundStyle(.secondary)
//            }
//        }
//    }
//}

//// MARK: – Preview
//#Preview {
//    NavigationStack {
//        EventDetailView(eventId: 1) { _ in
//            // 미리보기를 위한 목업 VM
//            let vm = EventDetailViewModel(eventId: 1, service: MockService())
//            vm.detail = .init(id: 1,
//                              title: "Sample 공연",
//                              poster: URL(string:"https://placehold.co/600x800")!,
//                              location: "홍대 Somewhere",
//                              period: Date() ... Calendar.current.date(byAdding: .day, value: 2, to: .now)!,
//                              timeRange: ("18:00","20:00"),
//                              ageLimit: .all,
//                              price: 49000,
//                              applyPeriod: .now ... .now,
//                              capacity: 500,
//                              status: .applyOpen,
//                              sessionIds: [10,11,12])
//            vm.state = .loaded
//            return vm
//        }
//    }
//}
