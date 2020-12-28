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
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var task: Task
    @State var isEditing = false
    @Binding var showBin: Bool
    
    var body: some View {
        if (task.binned == showBin) {
            HStack {
                HStack {
                    if (task.binned) {
                        Text(task.text!)
                    } else {
                        TextField("", text: $task.text.bound, onEditingChanged: { isEditing = $0 }).textFieldStyle(PlainTextFieldStyle()).colorMultiply(colourScheme.headerText).padding(5).background(colourScheme.headerBackground).foregroundColor(colourScheme.headerText)
                    }
                }
                Spacer()
                if (task.binned) {
                    Button(action: {
                        self.task.binned = false
                        if (self.taskStore.taskList.count(binned: true) == 0) {
                            showBin = false
                        }
                        self.taskStore.objectWillChange.send()
                    }) {
                        Image("Add Colour")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .shadow(radius: Constants.ShadowRadius)
                            .frame(width: Constants.ButtonWidth, height: Constants.ButtonHeight)
                    }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.ButtonLeadingPadding)
                    Button(action: {
                        self.task.binned = false
                        self.taskStore.taskList.remove(contentsOf: [task], in: managedObjectContext)
                        if (self.taskStore.taskList.count(binned: true) == 0) {
                            showBin = false
                        }
                        self.taskStore.objectWillChange.send()
                    }) {
                        Image("Remove Colour")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .shadow(radius: Constants.ShadowRadius)
                            .frame(width: Constants.ButtonWidth, height: Constants.ButtonHeight)
                    }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.ButtonLeadingPadding)
                } else {
                    Button(action: {
                        self.task.binned = true
                        self.taskStore.objectWillChange.send()
                    }) {
                        Image("Remove Colour")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .shadow(radius: Constants.ShadowRadius)
                            .frame(width: Constants.ButtonWidth, height: Constants.ButtonHeight)
                    }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.ButtonLeadingPadding)
                }
            }
        }
    }
}
