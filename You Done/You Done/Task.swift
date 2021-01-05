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
    @Published var date: Date = Date.today()
    @Published var taskList: TaskList = TaskList()
    @Published var isPulling = false

    
    private var context: NSManagedObjectContext
    private var alertContext: AlertContext
    private var integrationStore: IntegrationStore
    private var taskListObserver: AnyCancellable? = nil
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    
    func getDateString() -> String {
        if (date == Date.today()) {
            return "Today"
        } else if (date == Date.yesterday()) {
            return "Yesterday"
        } else {
            return dateFormatter.string(from: date)
        }
    }
    
    private func fetchTasks(date: Date = Date()) -> [Task] {
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
    
    init(context: NSManagedObjectContext, alertContext: AlertContext, integrationStore: IntegrationStore, date: Date = Date()) {
        self.context = context
        self.alertContext = alertContext
        self.integrationStore = integrationStore
        setDate(date)
    }
    
    func setDate(_ date: Date) {
        self.date = date.toDay()
        self.taskList = taskListByDate.getOrSet(date.toDay(), defaultValue: { TaskList(items: fetchTasks(date: date)) })
        self.taskListObserver = taskList.objectWillChange.sink(receiveValue: { _ in self.objectWillChange.send() })
        self.pull()
    }
    
    func pull(_ force: Bool = false) {
        if (force || UserDefaults.standard.bool(forKey: "Active Pull")) {
            let deadline = DispatchTime.now() + 1
            var errorList: [Error] = []
            isPulling = true
            integrationStore.all(forState: .installed).map { $0.pull(date: date) }.subscribe(onNext: { pulledEventList in
                self.taskList.append(contentsOf: pulledEventList, in: self.context)
            }, onError: { error in
                errorList.append(error)
            }, onFinal: {
                DispatchQueue.main.asyncAfter(deadline: deadline) {
                    self.isPulling = false
                }
                if (!errorList.isEmpty) {
                    self.alertContext.message = errorList.map { $0.localizedDescription }.joined(separator: "\n")
                }
            })
        }
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
                return event.label == nil || !self.items.contains { item in item.label == event.label }
            }.map { event -> Task in
                let task = Task(context: context)
                task.id = UUID()
                task.label = event.label
                task.text = event.text
                task.date = event.date
                task.day = event.date.toDay()
                return task
            }
            self.items.append(contentsOf: taskList)
        }
    }
    
    func remove(contentsOf list: [Task], in context: NSManagedObjectContext) {
        DispatchQueue.main.async {
            list.forEach { task in
                context.delete(task)
            }
            let idList = list.map { $0.id }
            self.items = self.items.filter { item in
                !idList.contains(item.id)
            }
        }
    }
    
    func removeAll(in context: NSManagedObjectContext) {
        remove(contentsOf: self.items, in: context)
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
