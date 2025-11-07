//
//  BuyerEnterCodeView.swift
//  Dket_iOS
//
//  Created by M-136 on 11/7/25.
//

import SwiftUI

struct BuyerEnterCodeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var codeDigits: [String] = Array(repeating: "", count: 4)
    @FocusState private var focusedField: Int?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("TicketDetail")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: - 상단 닫기 버튼
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                                .padding(20)
                        }
                    }
                    .padding(.trailing, 16)
                    .padding(.top, geometry.safeAreaInsets.top + 8)
                    
                    // MARK: - 안내 텍스트
                    VStack(spacing: 16) {
                        Text("입장 확인 전 안내")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color.dketBlue)
                        
                        VStack(spacing: 6) {
                            Text("입장은 공연장 스태프의 안내에 따라 진행해주세요.\n사용자가 임의로 입장 처리를 시도할 경우,\n티켓 사용이 제한될 수 있습니다.")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                            
                            Text("입장이 완료되면 해당 티켓으로는 다시 입장할 수 없습니다.")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal, 32)
                    }
                    .padding(.top, 20)
                    
                    Spacer(minLength: 20)
                    
                    // MARK: - 인증 코드 입력 영역
                    VStack(spacing: 20) {
                        Text("입장 절차를 계속 진행하려면\n스태프가 제공하는 4자리 인증번호를 입력해주세요.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 8)
                        
                        HStack(spacing: 16) {
                            ForEach(0..<4, id: \.self) { index in
                                OneDigitField(
                                    text: $codeDigits[index],
                                    isFocused: focusedField == index,
                                    onInput: { newValue in
                                        // 입력 시 자동 다음 칸 이동
                                        if !newValue.isEmpty && index < 3 {
                                            focusedField = index + 1
                                        } else if index == 3 && !newValue.isEmpty {
                                            focusedField = nil
                                        }
                                    },
                                    onDeleteBackward: {
                                        // 삭제 시 이전 칸으로 포커스만 이동
                                        if codeDigits[index].isEmpty && index > 0 {
                                            focusedField = index - 1
                                        }
                                    }
                                )
                                .frame(width: 55, height: 55)
                                .focused($focusedField, equals: index)
                            }
                        }
                        .padding(.bottom, 70)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    // MARK: - 하단 버튼
                    VStack(spacing: 14) {
                        Button(action: { dismiss() }) {
                            Text("돌아가기")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: 360, maxHeight: 48)
                                .background(Color.dketBlue)
                                .cornerRadius(24)
                                .shadow(radius: 4)
                        }
                        
                        Button(action: {
                            let code = codeDigits.joined()
                            print("입장 코드 입력됨: \(code)")
                            // TODO: 서버 검증 로직 추가 예정
                        }) {
                            Text("입장하기")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: 360, maxHeight: 48)
                                .background(isCodeComplete ? Color.dketBlue : Color.gray.opacity(0.5))
                                .cornerRadius(24)
                                .shadow(radius: 4)
                        }
                        .disabled(!isCodeComplete)
                    }
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 30)
                }
            }
            .onAppear { focusedField = 0 }
            .ignoresSafeArea(edges: .all)
        }
    }
    
    private var isCodeComplete: Bool {
        codeDigits.allSatisfy { $0.count == 1 }
    }
}

struct OneDigitField: UIViewRepresentable {
    @Binding var text: String
    var isFocused: Bool
    var onInput: (String) -> Void
    var onDeleteBackward: () -> Void
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.textAlignment = .center
        textField.font = UIFont.boldSystemFont(ofSize: 28)
        textField.keyboardType = .numberPad
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 10
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.1
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField.layer.shadowRadius = 2
        textField.delegate = context.coordinator
        
        // ✅ 명시적 크기 고정 (UI 늘어남 방지)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.widthAnchor.constraint(equalToConstant: 55).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        if isFocused && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        } else if !isFocused && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: OneDigitField
        
        init(_ parent: OneDigitField) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // ✅ 백스페이스 입력
            if string.isEmpty {
                parent.text = ""
                parent.onDeleteBackward()
                return false
            }
            
            // ✅ 숫자만 허용
            guard string.rangeOfCharacter(from: .decimalDigits) != nil else { return false }
            
            // ✅ 입력값 업데이트 및 다음칸 이동
            parent.text = String(string.prefix(1))
            parent.onInput(parent.text)
            return false
        }
    }
}

#Preview {
    BuyerEnterCodeView()
}
