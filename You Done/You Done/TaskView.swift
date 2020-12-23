//
//  TaskView.swift
//  You Done
//
//  Created by Piotr Galar on 09/12/2020.
//

import SwiftUI

struct TaskView: View {
    @EnvironmentObject var taskStore: TaskStore
    @EnvironmentObject var colourScheme: ColourScheme
    @ObservedObject var task: Task
    @State var isEditing = false
    @Binding var showDeleted: Bool
    
    var body: some View {
        if (task.deleted == showDeleted) {
            HStack {
                HStack {
                    if (task.deleted) {
                        Text(task.text)
                    } else {
                        TextField("", text: $task.text, onEditingChanged: { isEditing = $0 }).textFieldStyle(PlainTextFieldStyle()).colorMultiply(colourScheme.headerText).padding(5).background(colourScheme.headerBackground).foregroundColor(colourScheme.headerText)
                    }
                }
                Spacer()
                if (task.deleted) {
                    Button(action: {
                        self.task.deleted = false
                        if (self.taskStore.taskList.count(deleted: true) == 0) {
                            showDeleted = false
                        }
                        self.taskStore.objectWillChange.send()
                    }) {
                        Image("Add Colour")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Constants.ButtonWidth, height: Constants.ButtonHeight)
                            .shadow(radius: Constants.ShadowRadius)
                    }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.ButtonLeadingPadding)
                } else {
                    /*
                    Button(action: {}) {
                        Image(isEditing ? "Floppy Colour" : "Floppy")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Constants.ButtonWidth, height: Constants.ButtonHeight)
                            .shadow(radius: Constants.ShadowRadius)
                    }.buttonStyle(PlainButtonStyle()).disabled(!isEditing).padding(.leading, Constants.ButtonLeadingPadding)
                    */
                    Button(action: {
                        self.task.deleted = true
                        self.taskStore.objectWillChange.send()
                    }) {
                        Image("Remove Colour")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Constants.ButtonWidth, height: Constants.ButtonHeight)
                            .shadow(radius: Constants.ShadowRadius)
                    }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.ButtonLeadingPadding)
                }
            }
        }
    }
}
