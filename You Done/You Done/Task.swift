//
//  Task.swift
//  You Done
//
//  Created by Piotr Galar on 09/12/2020.
//

import SwiftUI
import Combine

extension Dictionary {
    mutating func getOrSet(_ key: Key, defaultValue: () -> Value) -> Value {
        if let value = self[key] {
            return value
        } else {
            self[key] = defaultValue()
            return self[key]!
        }
    }
}

class TaskStore: ObservableObject {
    private var taskListByDate: [Date:TaskList] = [:]
    @Published var date: Date
    @Published var taskList: TaskList
    
    private var taskListObserver: AnyCancellable? = nil
    
    init(date: Date = Date()) {
        self.date = date.toDay()
        self.taskList = taskListByDate.getOrSet(date.toDay(), defaultValue: { TaskList() })
        self.taskListObserver = taskList.objectWillChange.sink(receiveValue: { _ in self.objectWillChange.send() })
    }
    
    func setDate(_ date: Date) {
        self.date = date.toDay()
        self.taskList = taskListByDate.getOrSet(date.toDay(), defaultValue: { TaskList() })
        self.taskListObserver = taskList.objectWillChange.sink(receiveValue: { _ in self.objectWillChange.send() })
    }
}

class TaskList: ObservableObject, Equatable {
    static func == (lhs: TaskList, rhs: TaskList) -> Bool {
        return lhs.items == rhs.items
    }
    
    @Published var items: [Task] = []
    
    func count(deleted: Bool) ->  Int { items.filter { $0.deleted == deleted }.count }
    var isEmpty: Bool { items.isEmpty }
        
    func append(contentsOf list: [Task]) {
        DispatchQueue.main.async {
            var newTaskList = self.items
            newTaskList.append(contentsOf: list)
            self.items = newTaskList.unique()
        }
    }
    
    func reset() {
        DispatchQueue.main.async {
            self.items = []
        }
    }
    
    func toString(title: String) -> String {
        "\(title):\n\(items.filter { task in !task.deleted }.map { task in "- \(task.text)" }.joined(separator: "\n"))"
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
