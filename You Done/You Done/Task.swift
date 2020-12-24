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
    
    private var context: NSManagedObjectContext
    private var taskListObserver: AnyCancellable? = nil
    
    private static func fetchTasks(context: NSManagedObjectContext, date: Date = Date()) -> [Task] {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "day == %@", date.toDay() as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let taskController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        do {
          try taskController.performFetch()
        } catch {
          print("failed to fetch items!")
        }
        
        return taskController.fetchedObjects ?? []
    }
    
    init(context: NSManagedObjectContext, date: Date = Date()) {
        self.context = context
        self.date = date.toDay()
        self.taskList = taskListByDate.getOrSet(date.toDay(),
                                                defaultValue: { TaskList(items: TaskStore.fetchTasks(context: context, date: date)) }
        )
        self.taskListObserver = taskList.objectWillChange.sink(receiveValue: { _ in self.objectWillChange.send() })
    }
    
    func setDate(_ date: Date) {
        self.date = date.toDay()
        self.taskList = taskListByDate.getOrSet(date.toDay(),
                                                defaultValue: { TaskList(items: TaskStore.fetchTasks(context: context, date: date)) }
        )
        self.taskListObserver = taskList.objectWillChange.sink(receiveValue: { _ in self.objectWillChange.send() })
    }
}

class TaskList: ObservableObject, Equatable {
    static func == (lhs: TaskList, rhs: TaskList) -> Bool {
        return lhs.items == rhs.items
    }
    
    @Published var items: [Task] = []
    
    func count(binned: Bool) ->  Int { items.filter { $0.binned == binned }.count }
    var isEmpty: Bool { items.isEmpty }
        
    func append(contentsOf list: [EventData], in context: NSManagedObjectContext) {
        DispatchQueue.main.async {
            let taskList = list.filter { event in
                return !self.items.contains { item in item.id == event.id }
            }.map { event -> Task in
                let task = Task(context: context)
                task.id = event.id
                task.text = event.text
                task.date = event.date
                task.day = event.date.toDay()
                return task
            }
            self.items.append(contentsOf: taskList)
        }
    }
    
    func reset() {
        DispatchQueue.main.async {
            self.items = []
        }
    }
    
    func toString(title: String) -> String {
        "\(title):\n\(items.filter { task in !task.binned }.map { task in "- \(task.text!)" }.joined(separator: "\n"))"
    }
    
    init(items: [Task] = []) {
        self.items = items
    }
}
