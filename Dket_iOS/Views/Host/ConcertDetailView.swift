import SwiftUI

struct ConcertDetailView: View {
    private let concertId: Int64
    @Environment(\.dismiss) private var dismiss
    
    @State private var showScanner = false
    @State private var showTicketNumberEntry = false
    @State private var showVerifyAlert = false
    @State private var verifyTitle = ""
    @State private var verifyMessage = ""
    @State private var showTicketDetail = false
    @State private var showInvalidTicket = false
    
    @StateObject private var vm: ConcertDetailViewModel
    
    @MainActor
    init(concertId: Int64) {
        self.concertId = concertId
        _vm = StateObject(wrappedValue: ConcertDetailViewModel(concertId: concertId))
    }
    
    var body: some View {
        bodyView
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
            .fullScreenCover(isPresented: $showScanner) {
                QRScannerContainerView(
                    onScan: { code in
                        showScanner = false
                        vm.verifyTicket(with: code)
                    },
                    onManualTap: {
                        showScanner = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showTicketNumberEntry = true
                        }
                    }
                )
            }
            .fullScreenCover(isPresented: $showTicketDetail) {
                if let ticket = vm.verifiedTicket {
                    OrganizerTicketDetailView(ticket: ticket) {
                        showTicketDetail = false
                        vm.verifiedTicket = nil
                    }
                }
            }
            .fullScreenCover(isPresented: $showTicketNumberEntry) {
                OrganizerTicketNumberCheckView {
                    showTicketNumberEntry = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showScanner = true
                    }
                }
            }
            .onChange(of: vm.verificationState) { state in
                switch state {
                case .idle, .verifying:
                    break
                case .success(let message):
                    verifyTitle = "입장 확인 완료"
                    verifyMessage = message
                    showVerifyAlert = true
                case .failure(let error):
                    verifyTitle = "티켓 검증 실패"
                    verifyMessage = error
                    showVerifyAlert = true
                }
            }
            .onChange(of: vm.verifiedTicket) { ticket in
                if ticket != nil {
                    showTicketDetail = true
                }
            }
            .alert(verifyTitle, isPresented: $showVerifyAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(verifyMessage)
            }
    }
    
    @ViewBuilder
    private var bodyView: some View {
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
            if let detail = vm.detail {
                content(detail)
            }
        }
    }
    
    // MARK: - 티켓 검증 상태 처리
    private func handleVerificationState(_ state: ConcertDetailViewModel.VerificationState) {
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
    
    // MARK: - 메인 콘텐츠
    @ViewBuilder
    func content(_ d: ConcertDetail) -> some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    HStack {
                        Spacer()
                        PosterView(url: d.poster, status: d.status)
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        BasicInfoView(detail: d)
                        Divider()
                        
                        if d.status == .applyNotOpened {
                            Text("응모 D-\(Date().daysUntil(d.applyPeriod.lowerBound))일")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Divider()
                        } else {
                            SessionPickerView(detail: d)
                            Divider()
                            SessionStatSection()
                        }
                        
                        if !d.photoCards.isEmpty {
                            photoCardSection(d.photoCards)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 80)
                }
                .padding(.vertical, 12)
            }
            .refreshable { await vm.refresh() }
            
            if d.status == .inProgress {
                FloatingEnterButton()
            }
            
            if d.status == .ended {
                Color.black.opacity(0.4).ignoresSafeArea()
                Image("EndedEvent")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .opacity(0.9)
            }
        }
        .environmentObject(vm)
    }
    
    // MARK: - 입장 확인 플로팅 버튼
    @ViewBuilder
    private func FloatingEnterButton() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: { showScanner = true }) {
                    Label("공연 입장 확인하기", systemImage: "ticket.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: 360, maxHeight: 48)
                        .background(isTodaySession ? Color.dketBlue : Color.gray.opacity(0.5))
                        .cornerRadius(24)
                        .shadow(radius: 4)
                }
                .disabled(!isTodaySession)
            }
            .padding()
        }
    }
    
    private var isTodaySession: Bool {
        guard let s = vm.selectedSession else { return false }
        let today = Calendar.current.startOfDay(for: Date())
        let sessionDay = Calendar.current.startOfDay(for: s.date)
        return today == sessionDay
    }
    
    @ViewBuilder
    private func photoCardSection(_ photoCards: [PhotoCardItem]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("포토카드")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(photoCards, id: \.photoCardId) { photo in
                        AsyncImage(url: URL(string: photo.imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 80, height: 100)
                            case .success(let img):
                                img
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 100)
                                    .clipped()
                                    .cornerRadius(8)
                            case .failure:
                                Color.gray.opacity(0.2)
                                    .overlay(Image(systemName: "photo"))
                                    .frame(width: 80, height: 100)
                                    .cornerRadius(8)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

private struct SessionStatSection: View {
    @EnvironmentObject private var vm: ConcertDetailViewModel
    
    var body: some View {
        if let detail = vm.detail, let s = vm.selectedSession {
            VStack(alignment: .leading, spacing: 15) {
                Text(s.date.formatted(.dateTime.year().month().day()))
                    .font(.title3).bold()
                
                Group {
                    let (title, count): (String, Int) = {
                        switch detail.status {
                        case .applyOpen:
                            return ("응모자 수", s.applyCount)
                        case .applyClosed, .ticketed:
                            return ("예매자 수", s.paidCount ?? 0)
                        case .inProgress:
                            return ("입장 완료 수", s.attendeeCount ?? 0)
                        case .ended:
                            return ("관람자 수", s.attendeeCount ?? 0)
                        default:
                            return ("", 0)
                        }
                    }()
                    
                    HStack {
                        Text(title)
                            .font(.caption)
                        Spacer()
                        Text("\(count)명")
                    }
                    
                    if detail.status != .applyNotOpened && detail.status != .ended {
                        let percent = detail.capacity > 0
                        ? Double(count) / Double(detail.capacity)
                        : 0
                        HStack {
                            Text({
                                switch detail.status {
                                case .applyOpen:
                                    return "응모 달성률"
                                case .inProgress:
                                    return "입장 달성률"
                                default:
                                    return "예매 달성률"
                                }
                            }())
                            .font(.caption)
                            
                            Spacer()
                            Text("\(Int(percent * 100))%")
                                .bold()
                                .font(.caption)
                        }
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
