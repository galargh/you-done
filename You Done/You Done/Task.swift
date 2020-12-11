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
        DispatchQueue.main.sync {
            var newTaskList = self.taskList
            newTaskList.append(contentsOf: list)
            self.taskList = newTaskList.unique()
        }
    }
    
    func reset() {
        DispatchQueue.main.sync {
            self.taskList = []
        }
    }
    
    var isEmpty: Bool {
        taskList.isEmpty
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
