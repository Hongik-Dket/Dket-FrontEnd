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
                    .opacity(0.9)
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
