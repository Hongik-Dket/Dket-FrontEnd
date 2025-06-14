//
//  FirstStepView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/25/25.
//

import SwiftUI

struct EventSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var step: Step = .one
    @StateObject private var viewModel = EventSetupViewModel()
    
    // STEP 1
    @State private var title = ""
    @State private var ageFilter: String?
    @State private var location = ""
    @State private var description = ""
    
    // STEP 2
    @State private var performanceStart = Date()
    @State private var performanceEnd   = Date()
    @State private var startTime        = Date()
    @State private var endTime          = Date()
    @State private var price            = ""
    @State private var capacity         = ""
    @State private var enrollStartDate = Date()
    @State private var enrollStartTime = Date()
    @State private var enrollEndDate   = Date()
    @State private var enrollEndTime   = Date()
    
    // STEP 3
    @State private var bannerImage: UIImage?
    @State private var posterImage: UIImage?
    @State private var photocardImage: UIImage?
    
    // MARK: – 최종 모달 플로우
    @State private var showModal = false
    @State private var modalStep = 1   // 1,2,3 단계를 PopupFlowView 에 전달
    @State private var showNotice = false     // 개최 완료 공지
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    enum Step { case one, two, three }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: A) 커스텀 백헤더
            BackHeaderView(
                onBack: { dismiss() },
                onMenu: { /* 메뉴 토글 */ }
            )
            
            // MARK: B) STEP 인디케이터
            StepIndicatorView(current: step)
                .padding(.vertical, 8)
            Divider()
            
            // MARK: C) STEP 콘텐츠
            Group {
                switch step {
                case .one: FirstStepView(
                    title: $title,
                    ageFilter: $ageFilter,
                    location: $location,
                    description: $description
                )
                case .two:
                    SecondStepView(
                        performanceStart: $performanceStart,
                        performanceEnd:   $performanceEnd,
                        startTime:        $startTime,
                        endTime:          $endTime,
                        price:            $price,
                        capacity:         $capacity,
                        enrollStartDate:  $enrollStartDate,
                        enrollStartTime:  $enrollStartTime,
                        enrollEndDate:    $enrollEndDate,
                        enrollEndTime:    $enrollEndTime
                    )
                case .three:
                    ThirdStepView(
                        bannerImage: $bannerImage,
                        posterImage: $posterImage,
                        photocardImage: $photocardImage
                    )
                }
            }
            .padding()
            .animation(.easeInOut, value: step)
            
            Spacer()
            
            if showNotice {
                Text("🎉 공연이 성공적으로 등록되었습니다!")
                    .font(.system(size: 16, weight: .medium))
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // MARK: D) 하단 이전/다음 버튼
            HStack(spacing: 12) {
                if step != .one {
                    Button("이전으로") { back() }
                        .buttonStyle(PrimaryButtonStyle(filled: true))
                        .font(.system(size: 16, weight: .bold))
                }
                Button(step == .three ? "개최하기" : "다음으로") { next() }
                    .buttonStyle(PrimaryButtonStyle(filled: isNextEnabled))
                    .disabled(!isNextEnabled)
            }
            .padding(.horizontal)
            .padding(.bottom, 70)
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(true)
        .sheet(isPresented: $showModal) {
            PopupFlowView(
                step: $modalStep,
                isPresented: $showModal,
                onComplete: {
                    withAnimation { showNotice = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }
                },
                viewModel: viewModel
            )
        }
        
        // 뷰모델 상태 변화를 관찰해서 모달 띄우기
        .onReceive(viewModel.$state) { state in
            if case .loaded = state {
                modalStep = 1
                showModal = true
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("입력 오류"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
        }
    }
    
    private func next() {
        switch step {
        case .one:   step = .two
        case .two:
            let calendar = Calendar(identifier: .gregorian)

            guard
                let finalApplyStart = calendar.date(
                    bySettingHour: calendar.component(.hour, from: enrollStartTime),
                    minute: calendar.component(.minute, from: enrollStartTime),
                    second: 0,
                    of: enrollStartDate
                ),
                let finalApplyEnd = calendar.date(
                    bySettingHour: calendar.component(.hour, from: enrollEndTime),
                    minute: calendar.component(.minute, from: enrollEndTime),
                    second: 0,
                    of: enrollEndDate
                )
            else {
                alertMessage = "응모 시작/종료 시간이 올바르지 않습니다."
                showingAlert = true
                return
            }

            // 현재 시각보다 이후여야 함
            if finalApplyStart < Date() {
                alertMessage = "응모 시작 시간은 현재 시각보다 이후여야 합니다."
                showingAlert = true
                return
            }

            if finalApplyEnd <= finalApplyStart {
                alertMessage = "응모 마감일은 시작일보다 이후여야 합니다."
                showingAlert = true
                return
            }

            if calendar.date(byAdding: .day, value: 2, to: finalApplyEnd)! > calendar.startOfDay(for: performanceStart) {
                alertMessage = "응모 마감 후 최소 2일 후에 공연이 시작되어야 합니다."
                showingAlert = true
                return
            }

            if performanceEnd < performanceStart {
                alertMessage = "공연 종료일은 시작일보다 이후여야 합니다."
                showingAlert = true
                return
            }
            step = .three
            
        case .three: // 로컬 @State → 뷰모델로 복사
            // 응모 시작/종료 시간 조합
            let calendar = Calendar(identifier: .gregorian)
            let startDateTime = calendar.date(
                bySettingHour: calendar.component(.hour, from: enrollStartTime),
                minute: calendar.component(.minute, from: enrollStartTime),
                second: 0,
                of: enrollStartDate
            )
            let endDateTime = calendar.date(
                bySettingHour: calendar.component(.hour, from: enrollEndTime),
                minute: calendar.component(.minute, from: enrollEndTime),
                second: 0,
                of: enrollEndDate
            )
            
            guard let finalApplyStart = startDateTime, let finalApplyEnd = endDateTime else {
                print("⛔️ 응모 시작/종료 시간 결합 실패")
                return
            }
            
            // viewModel에 복사
            viewModel.title          = title
            viewModel.location       = location
            viewModel.description    = description
            viewModel.startDate      = performanceStart
            viewModel.endDate        = performanceEnd
            viewModel.startTimeText  = DateFormatter.HHmm.string(from: startTime)
            viewModel.endTimeText    = DateFormatter.HHmm.string(from: endTime)
            viewModel.price          = Int(price) ?? 0
            viewModel.capacity       = Int(capacity) ?? 0
            viewModel.applyStart     = finalApplyStart
            viewModel.applyEnd       = finalApplyEnd
            viewModel.bannerImageData    = bannerImage?.jpegData(compressionQuality: 0.8)
            viewModel.posterImageData    = posterImage?.jpegData(compressionQuality: 0.8)
            viewModel.photocardImageData = photocardImage?.jpegData(compressionQuality: 0.8)
            
            modalStep = 1
            showModal = true
        }
    }
    private func back() {
        switch step {
        case .one:   break
        case .two:   step = .one
        case .three: step = .two
        }
    }
    private var isNextEnabled: Bool {
        switch step {
        case .one:
            return !title.isEmpty &&
            ageFilter != nil &&
            !location.isEmpty &&
            !description.isEmpty
        case .two:
            return performanceStart <= performanceEnd
            && startTime       <= endTime
            && !price.isEmpty
            && !capacity.isEmpty
        case .three:
            return bannerImage != nil && posterImage != nil
        }
    }
        
    
}

struct EventSetupStep1View_Previews: PreviewProvider {
    static var previews: some View {
        EventSetupView()
    }
}
