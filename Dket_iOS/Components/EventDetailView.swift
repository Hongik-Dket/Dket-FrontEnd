//import SwiftUI
//
//struct EventDetailView: View {
//    let event: Event
//    @Environment(\.dismiss) private var dismiss
//    
//    // 시트 높이
//    private let minHeight: CGFloat = 120
//    private let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.75
//    @State private var sheetOffset: CGFloat = UIScreen.main.bounds.height * 0.4
//    @State private var prevDragTranslation: CGFloat = 0
//    
//    var body: some View {
//        NavigationStack {
//            ZStack(alignment: .top) {
//                // 1) 헤더뷰 (커스텀 BackHeaderView)
//                BackHeaderView(
//                    onBack: { dismiss() },
//                    onMenu: { /* 메뉴 토글 처리 */ }
//                )
//                
//                // 2) 공연 배너
//                Rectangle()
//                    .fill(Color.gray.opacity(0.3))
//                    .frame(height: UIScreen.main.bounds.height * 0.45)
//                    .overlay(
//                        Image(systemName: "photo")
//                            .font(.system(size: 60))
//                            .foregroundColor(.gray)
//                    )
//                    .padding(.top, 90) // 헤더높이(50pt) 만큼 내려놓기
//                
//                // 3) 드래그 가능한 시트
//                VStack(spacing: 0) {
//                    Capsule()
//                        .fill(Color.white.opacity(0.8))
//                        .frame(width: 40, height: 5)
//                        .padding(.vertical, 8)
//                    
//                    ScrollView {
//                        detailContent()
//                            .padding(.horizontal, 20)
//                            .padding(.bottom, 30)
//                    }
//                }
//                .background(Color(red: 22/255, green: 29/255, blue: 111/255))
//                .cornerRadius(16, corners: [.topLeft, .topRight])
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//                .offset(y: sheetOffset)
//                .gesture(dragGesture)
//            }
//            .navigationBarHidden(true)
//        }
//    }
//    
//    // 드래그 제스처
//    private var dragGesture: some Gesture {
//        DragGesture()
//            .onChanged { value in
//                let delta = value.translation.height - prevDragTranslation
//                let newOffset = sheetOffset + delta
//                let lower = UIScreen.main.bounds.height - maxHeight
//                let upper = UIScreen.main.bounds.height - minHeight
//                sheetOffset = min(max(newOffset, lower), upper)
//                prevDragTranslation = value.translation.height
//            }
//            .onEnded { _ in
//                let mid = UIScreen.main.bounds.height - (minHeight + maxHeight)/2
//                withAnimation(.easeOut) {
//                    if sheetOffset < mid {
//                        sheetOffset = UIScreen.main.bounds.height - maxHeight
//                    } else {
//                        sheetOffset = UIScreen.main.bounds.height - minHeight
//                    }
//                }
//                prevDragTranslation = 0
//            }
//    }
//
//    @ViewBuilder
//    private func detailContent() -> some View {
//        Text(event.name)
//            .font(.title2).foregroundColor(.white)
//            .padding(.bottom, 12)
//        
//        Group {
//            detailRow("장소",   event.location)
//            detailRow("기간",   event.dateRange)
//            if event.state == .preEnrollment {
//                detailRow("응모 시작",     event.enrollmentStart)
//                detailRow("응모 마감",     event.enrollmentEnd)
//            }
//            detailRow("상태", event.state.label)
//        }
//        .foregroundColor(.white)
//        .font(.body)
//        .padding(.vertical, 4)
//    }
//
//    private func detailRow(_ title: String, _ value: String) -> some View {
//        HStack {
//            Text(title).bold()
//            Spacer()
//            Text(value)
//        }
//    }
//}
//
//// top corners만 라운딩
//fileprivate extension View {
//    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
//        clipShape( RoundedCorner(radius: radius, corners: corners) )
//    }
//}
//
//fileprivate struct RoundedCorner: Shape {
//    var radius: CGFloat
//    var corners: UIRectCorner
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(
//            roundedRect: rect,
//            byRoundingCorners: corners,
//            cornerRadii: CGSize(width: radius, height: radius)
//        )
//        return Path(path.cgPath)
//    }
//}
