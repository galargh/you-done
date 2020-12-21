//
//  StatusView.swift
//  You Done
//
//  Created by Piotr Galar on 08/12/2020.
//

import SwiftUI

struct StatusView: View {
    @EnvironmentObject var integrationStore: IntegrationStore
    @Binding var date: Date
    @ObservedObject var taskList: TaskList

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    
    @State private var dateString = "Today"
    @State private var showDatePicker = false
    

    private func setDate(_ date: Date) {
        self.date = date
        self.taskList.reset()
        self.showDatePicker = false
        refreshDateString()
        loadTaskList()
    }
    
    private func refreshDateString() {
        if (date.toDay() == Date.today) {
            self.dateString = "Today"
        } else if (date.toDay() == Date.yesterday) {
            self.dateString = "Yesterday"
        } else {
            self.dateString = dateFormatter.string(from: date)
        }
    }
    
    @State private var alert: String?
    @State private var isPulling = false
    private func loadTaskList(force: Bool = true) {
        if (taskList.isEmpty || force) {
            let deadline = DispatchTime.now() + 1
            var errorList: [Error] = []
            isPulling = true
            integrationStore.all(forState: .installed).map { $0.pull(date: date) }.subscribe(onNext: { pulledTaskList in
                taskList.append(contentsOf: pulledTaskList)
            }, onError: { error in
                errorList.append(error)
            }, onFinal: {
                DispatchQueue.main.asyncAfter(deadline: deadline) {
                    isPulling = false
                }
                if (!errorList.isEmpty) {
                    self.alert = errorList.map { $0.localizedDescription }.joined(separator: "\n")
                }
            })
        }
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
                                get: { return self.date },
                                set: { setDate($0) }
                            ), in: ...Date(), displayedComponents: .date).datePickerStyle(GraphicalDatePickerStyle())
                                .labelsHidden()
                        }
                    Spacer()
                    Button(action: {
                        loadTaskList(force: true)
                    }) {
                        Image(isPulling ? "Sync" : "Sync Colour")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .rotationEffect(Angle(degrees: isPulling ? 360 : 0.0))
                            .animation(isPulling ? foreverAnimation : .default)
                            .frame(width: Constants.BigButtonWidth, height: Constants.BigButtonHeight)
                    }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.BigButtonLeadingPadding).disabled(isPulling)
                    .modifier(AlertSheet(alert: $alert))
                }
                if (self.taskList.taskList.isEmpty) {
                    Button(action: {
                        self.taskList.append(contentsOf: [Task(text: "New task")])
                    }) {
                        Image("Unicorn").resizable().aspectRatio(contentMode: .fit)
                    }.buttonStyle(PlainButtonStyle())
                } else {
                    ScrollView(showsIndicators: taskList.taskList.count > 8) {
                        VStack {
                            ForEach(self.taskList.taskList) { task in
                                TaskView(task: task)
                            }
                            HStack {
                                Spacer()
                                Button(action: {
                                    self.taskList.append(contentsOf: [Task(text: "New task")])
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
                    pasteBoard.writeObjects([taskList.toString(title: dateString) as NSString])
                }) {
                    Image(self.taskList.taskList.isEmpty ? "File" : "File Colour")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.BigButtonWidth, height: Constants.BigButtonHeight)
                }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.BigButtonLeadingPadding).disabled(self.taskList.taskList.isEmpty)
                Button(action: {}) {
                    Image("Send")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.BigButtonWidth, height: Constants.BigButtonHeight)
                }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.BigButtonLeadingPadding).disabled(true)
            }
        }.onAppear {
            refreshDateString()
            loadTaskList(force: false)
        }
    }
}
