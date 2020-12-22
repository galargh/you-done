//
//  StatusView.swift
//  You Done
//
//  Created by Piotr Galar on 08/12/2020.
//

import SwiftUI

struct StatusView: View {
    @EnvironmentObject var integrationStore: IntegrationStore
    @EnvironmentObject var taskStore: TaskStore

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    
    @State private var dateString = "Today"
    @State private var showDatePicker = false
    

    private func setDate(_ date: Date) {
        self.taskStore.setDate(date)
        self.showDatePicker = false
        refreshDateString()
        loadTaskList()
    }
    
    private func refreshDateString() {
        if (self.taskStore.date == Date.today) {
            self.dateString = "Today"
        } else if (self.taskStore.date == Date.yesterday) {
            self.dateString = "Yesterday"
        } else {
            self.dateString = dateFormatter.string(from: self.taskStore.date)
        }
    }
    
    @EnvironmentObject var alertContext: AlertContext
    @State private var isPulling = false
    private func loadTaskList() {
        let deadline = DispatchTime.now() + 1
        var errorList: [Error] = []
        isPulling = true
        integrationStore.all(forState: .installed).map { $0.pull(date: taskStore.date) }.subscribe(onNext: { pulledTaskList in
            taskStore.taskList.append(contentsOf: pulledTaskList)
        }, onError: { error in
            errorList.append(error)
        }, onFinal: {
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                isPulling = false
            }
            if (!errorList.isEmpty) {
                self.alertContext.message = errorList.map { $0.localizedDescription }.joined(separator: "\n")
            }
        })
    }
    
    private var foreverAnimation: Animation {
        Animation.linear(duration: 4.0)
            .repeatForever(autoreverses: false)
    }

    var body: some View {
        VStack {
            Group {
                HStack {
                    Text(dateString)
                        .bold()
                        .font(.system(size: 24.0))
                        .onTapGesture {
                            showDatePicker.toggle()
                        }
                        .popover(
                            isPresented: $showDatePicker,
                            arrowEdge: .bottom
                        ) {
                            DatePicker("?", selection: Binding(
                                get: { return self.taskStore.date },
                                set: { setDate($0) }
                            ), in: ...Date(), displayedComponents: .date).datePickerStyle(GraphicalDatePickerStyle())
                                .labelsHidden()
                        }
                    Spacer()
                    Button(action: {
                        loadTaskList()
                    }) {
                        Image(isPulling ? "Sync" : "Sync Colour")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .rotationEffect(Angle(degrees: isPulling ? 360 : 0.0))
                            .animation(isPulling ? foreverAnimation : .default)
                            .frame(width: Constants.BigButtonWidth, height: Constants.BigButtonHeight)
                    }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.BigButtonLeadingPadding).disabled(isPulling)
                }
                if (self.taskStore.taskList.isEmpty) {
                    Button(action: {
                        self.taskStore.taskList.append(contentsOf: [Task(text: "New task")])
                    }) {
                        Image("Unicorn").resizable().aspectRatio(contentMode: .fit)
                    }.buttonStyle(PlainButtonStyle())
                } else {
                    ScrollView(showsIndicators: taskStore.taskList.count > 8) {
                        VStack {
                            ForEach(self.taskStore.taskList.items) { task in
                                TaskView(task: task)
                            }
                            HStack {
                                Spacer()
                                Button(action: {
                                    self.taskStore.taskList.append(contentsOf: [Task(text: "New task")])
                                }) {
                                    Image("Add Colour")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: Constants.ButtonWidth, height: Constants.ButtonHeight)
                                    
                                }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.ButtonLeadingPadding)
                            }
                        }
                    }
                }
                Spacer()
            }
            HStack {
                Spacer()
                Button(action: {
                    let pasteBoard = NSPasteboard.general
                    pasteBoard.clearContents()
                    pasteBoard.writeObjects([self.taskStore.taskList.toString(title: dateString) as NSString])
                }) {
                    Image(self.taskStore.taskList.isEmpty ? "File" : "File Colour")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.BigButtonWidth, height: Constants.BigButtonHeight)
                }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.BigButtonLeadingPadding).disabled(self.taskStore.taskList.isEmpty)
                Button(action: {}) {
                    Image("Send")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.BigButtonWidth, height: Constants.BigButtonHeight)
                }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.BigButtonLeadingPadding).disabled(true)
            }
        }.onAppear {
            refreshDateString()
        }
    }
}
