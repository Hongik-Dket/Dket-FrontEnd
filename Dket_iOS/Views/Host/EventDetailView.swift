import SwiftUI

struct EventDetailView: View {
    // MARK: – DI
    private let eventId: Int64
    
    // MARK: – VM
    @StateObject private var vm: EventDetailViewModel
    
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
    }
    
    @ViewBuilder
    func content(_ d: EventDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                PosterView(url: d.poster)
                BasicInfoView(detail: d)
                Divider()
                SessionPickerView(detail: d)
                SessionStatSection()
                Spacer(minLength: 40)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .environmentObject(vm)
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
            Text("회차 선택").font(.headline)
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
        if let s = vm.sessionCache[id] {
            Text(s.date.formatted(.dateTime.year().month().day()))
        } else {
            Text("세션 \(id)")
        }
    }
}

private struct BasicInfoView: View {
    let detail: EventDetail
    private var periodText: String {
        let df = DateFormatter.yyyyMMdd     // ⬅︎ 기존 전역 포맷터 재활용
        return "\(df.string(from: detail.period.lowerBound))"
        + " - "
        + "\(df.string(from: detail.period.upperBound))"
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(detail.title).font(.title2).bold()
            Text(detail.location)
                .font(.callout).foregroundStyle(.secondary)
            Text(periodText)
            Text("\(detail.timeRange.start) – \(detail.timeRange.end)")
                .font(.subheadline)
            HStack {
                Text(detail.ageLimit.label)
                Spacer()
                Text("\(detail.price.formatted()) 원")
            }.font(.footnote)
        }
    }
}

private struct SessionStatSection: View {
    @EnvironmentObject private var vm: EventDetailViewModel
    
    var body: some View {
        Group {
            if let s = vm.selectedSession {
                VStack(alignment: .leading, spacing: 12) {
                    Text(s.date.formatted(.dateTime.year().month().day()))
                        .font(.title3).bold()
                    HStack {
                        StatBlock(title: "응모", value: s.applyCount)
                        Spacer()
                        StatBlock(title: "예매", value: s.paidCount)
                        Spacer()
                        StatBlock(title: "입장", value: s.attendeeCount)
                    }
                    .padding()
                    .background(.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            } else {
                ProgressView().frame(maxWidth: .infinity)
            }
        }
    }
    
    private struct StatBlock: View {
        let title: String
        let value: Int?
        var body: some View {
            VStack {
                Text(title).font(.caption)
                if let v = value {
                    Text("\(v)").bold()
                } else {
                    Text("-").foregroundStyle(.secondary)
                }
            }
        }
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
