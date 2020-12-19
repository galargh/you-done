//
//  StatusView.swift
//  You Done
//
//  Created by Piotr Galar on 08/12/2020.
//

import SwiftUI

struct StatusView: View {
    @EnvironmentObject var integrationStore: IntegrationStore
    @ObservedObject var taskList: TaskList

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
    
    @State private var pullingCounter = 0
    private var isPulling: Bool { pullingCounter != 0 }
    private func loadTaskList(force: Bool = true) {
        if (taskList.isEmpty || force) {
            pullingCounter += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                pullingCounter -= 1
            }
            integrationStore.all(forState: .installed).forEach { integration in
                pullingCounter += 1
                integration.pull(date: date).subscribe(
                    onNext: { pulledTaskList in
                        taskList.append(contentsOf: pulledTaskList)
                        pullingCounter -= 1
                    },
                    onError: { error in
                        print(error)
                        pullingCounter -= 1
                    }
                )
            }
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
                                set: { self.date = $0; self.taskList.reset(); loadTaskList() }
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
                Button(action: { print("Send") }) {
                    Image("Send")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.BigButtonWidth, height: Constants.BigButtonHeight)
                }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.BigButtonLeadingPadding).disabled(true)
            }
            
        }.onAppear { loadTaskList(force: false) }
    }
}
