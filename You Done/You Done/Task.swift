//
//  Task.swift
//  You Done
//
//  Created by Piotr Galar on 09/12/2020.
//

import SwiftUI

class TaskList: ObservableObject {
    @Published var taskList: [Task] = []
        
    func append(contentsOf list: [Task]) {
        DispatchQueue.main.async {
            var newTaskList = self.taskList
            newTaskList.append(contentsOf: list)
            self.taskList = newTaskList.unique()
        }
    }
    
    func reset() {
        DispatchQueue.main.async {
            self.taskList = []
        }
    }
    
    var isEmpty: Bool {
        taskList.isEmpty
    }
    
    func toString(title: String) -> String {
        "\(title):\n\(taskList.map { task in "- \(task.text)" }.joined(separator: "\n"))"
    }
}

class Task: ObservableObject, Identifiable, Equatable, Hashable {
    static func == (lhs: Task, rhs: Task) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String
    @Published var text: String
    @Published var deleted: Bool
    
    init(id: String = UUID().description, text: String, deleted: Bool = false) {
        self.id = id
        self.text = text
        self.deleted = deleted
    }
}
