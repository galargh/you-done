//
//  TaskView.swift
//  You Done
//
//  Created by Piotr Galar on 09/12/2020.
//

import SwiftUI

struct TaskView: View {
    @ObservedObject var task: Task
    @State var isEditing = false
    
    var body: some View {
        if (!task.deleted) {
            HStack {
                HStack {
                    TextField("", text: $task.text, onEditingChanged: { isEditing = $0 }).textFieldStyle(PlainTextFieldStyle())
                }.shadow(radius: Constants.ShadowRadius)
                Spacer()
                Button(action: {}) {
                    Image(isEditing ? "Floppy Colour" : "Floppy")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.ButtonWidth, height: Constants.ButtonHeight)
                        .shadow(radius: Constants.ShadowRadius)
                }.buttonStyle(PlainButtonStyle()).disabled(!isEditing).padding(.leading, Constants.ButtonLeadingPadding)
                Button(action: { self.task.deleted = true }) {
                    Image("Dump Colour")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.ButtonWidth, height: Constants.ButtonHeight)
                        .shadow(radius: Constants.ShadowRadius)
                }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.ButtonLeadingPadding)
            }
        }
    }
}
