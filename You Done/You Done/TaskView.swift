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
                TextField(
                    "",
                    text: Binding(
                        get: { return self.task.text },
                        set: { self.task.text = $0 }
                    ),
                    onEditingChanged: { isEditing = $0 },
                    onCommit: {
                        print("commit")
                    }
                ).textFieldStyle(PlainTextFieldStyle())
                Spacer()
                Button(action: { print("Save") }) {
                    Image(isEditing ? "Floppy Colour" : "Floppy")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.ButtonWidth, height: Constants.ButtonHeight)
                    
                }.buttonStyle(PlainButtonStyle()).disabled(!isEditing).padding(.leading, Constants.ButtonLeadingPadding)
                Button(action: { self.task.deleted = true }) {
                    Image("Dump Colour")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.ButtonWidth, height: Constants.ButtonHeight)
                }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.ButtonLeadingPadding)
            }
        }
    }
}
