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
                )
                Spacer()
                Button(action: { print("Save") }) { Text("Save") }.disabled(!isEditing)
                Button(action: { self.task.deleted = true; print(self.task.deleted) }) { Text("Delete") }
            }
        }
    }
}
