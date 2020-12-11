//
//  StatusView.swift
//  You Done
//
//  Created by Piotr Galar on 08/12/2020.
//

import SwiftUI

struct StatusView: View {
    @EnvironmentObject var integrationStore: IntegrationStore
    @State var taskList: [Task] = []
    private let taskQueue = DispatchQueue(label: "serial.task.queue")

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }

    @State private var date = Date()
    @State private var showDatePicker = false
    private var dateString: String {
        date.toDay() == Date().toDay() ? "Today" : dateFormatter.string(from: date)
    }
    private func loadTaskList(force: Bool = true) {
        if (taskList.isEmpty || force) {
            integrationStore.all(forState: .installed).forEach { integration in
                integration.pull(date: date).subscribe(
                    onNext: { pulledTaskList in
                        taskQueue.async {
                            var newTaskList = taskList
                            newTaskList.append(contentsOf: pulledTaskList)
                            taskList = newTaskList.unique()
                        }
                    },
                    onError: { error in
                        print(error)
                    }
                )
            }
        }
    }

    var body: some View {
        VStack {
            Group {
                HStack {
                    Text(dateString)
                        .onTapGesture {
                            showDatePicker.toggle()
                        }
                        .popover(
                            isPresented: $showDatePicker,
                            arrowEdge: .bottom
                        ) {
                            DatePicker("?", selection: Binding(
                                get: { return self.date },
                                set: { self.date = $0; self.taskList = []; loadTaskList() }
                            ), in: ...Date(), displayedComponents: .date).datePickerStyle(GraphicalDatePickerStyle())
                                .labelsHidden()
                        }
                    Spacer()
                    Button(action: {
                        loadTaskList(force: true)
                    }) {
                        Text("Pull")
                    }
                }
                ScrollView {
                    VStack {
                        ForEach(taskList) { task in
                            TaskView(text: task.text)
                        }
                    }
                }
                Spacer()
            }
            HStack {
                Spacer()
                Button(action: { print("Copy") }) { Text("Copy") }
                Button(action: { print("Send") }) { Text("Send") }
            }
            
        }.onAppear { loadTaskList(force: false) }
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatusView()
    }
}
