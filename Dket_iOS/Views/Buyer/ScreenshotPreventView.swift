//
//  ScreenshotPreventView.swift
//  Dket_iOS
//
//  Created by M-136 on 11/26/25.
//

import SwiftUI

struct ScreenshotPreventView<Content: View>: UIViewRepresentable {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeUIView(context: Context) -> UIView {
        // 1. 보안 텍스트 필드 생성 (비밀번호 입력 모드)
        let secureTextField = UITextField()
        secureTextField.isSecureTextEntry = true
        
        // 2. 텍스트 필드 내부의 보안 컨테이너 찾기
        // isSecureTextEntry가 true면, 내부적으로 캡처 방지용 뷰(CanvasView)가 생성됩니다.
        guard let secureView = secureTextField.subviews.first else {
            return secureTextField
        }
        
        // 3. 기존의 텍스트 필드 UI 요소 제거 (커서, 텍스트 입력창 등 안 보이게)
        secureView.subviews.forEach { $0.removeFromSuperview() }
        
        // 4. SwiftUI 뷰를 호스팅할 컨트롤러 생성
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = .clear // 배경 투명하게
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // 5. 보안 뷰 안에 SwiftUI 뷰 추가
        secureView.addSubview(hostingController.view)
        
        // 6. 오토레이아웃 설정 (화면 꽉 채우기)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: secureView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: secureView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: secureView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: secureView.trailingAnchor)
        ])
        
        return secureTextField
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // 뷰 업데이트 로직 (보통 불필요)
    }
}
