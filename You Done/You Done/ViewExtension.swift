//
//  View.swift
//  You Done
//
//  Created by Piotr Galar on 09/12/2020.
//

import SwiftUI

struct VisibilityStyle: ViewModifier {
   @Binding var hidden: Bool
   func body(content: Content) -> some View {
      Group {
         if hidden {
            content.hidden()
         } else {
            content
         }
      }
   }
}

extension View {
   func visibility(hidden: Binding<Bool>) -> some View {
      modifier(VisibilityStyle(hidden: hidden))
   }
}
