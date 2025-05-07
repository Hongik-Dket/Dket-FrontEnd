//
//  HideKeyboard.swift
//  Dket_iOS
//
//  Created by 이지우 on 5/7/25.
//

import SwiftUICore
import SwiftUI
import UIKit

extension View {
  func hideKeyboardOnTap() -> some View {
    modifier(HideKeyboardOnTap())
  }
}

private struct HideKeyboardOnTap: ViewModifier {
  func body(content: Content) -> some View {
    content
      .background(
        Color.clear
          .contentShape(Rectangle())
          .onTapGesture { UIApplication.shared
                                .sendAction(#selector(UIResponder.resignFirstResponder),
                                            to: nil, from: nil, for: nil) }
      )
      .gesture(
        DragGesture().onChanged { _ in
          UIApplication.shared
            .sendAction(#selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil)
        }
      )
  }
}
