//
//  StatusView.swift
//  You Done
//
//  Created by Piotr Galar on 08/12/2020.
//

import SwiftUI

struct StatusView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var integrationStore: IntegrationStore
    @EnvironmentObject var taskStore: TaskStore
    
    @Binding var showBin: Bool

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
        integrationStore.all(forState: .installed).map { $0.pull(date: taskStore.date) }.subscribe(onNext: { pulledEventList in
            taskStore.taskList.append(contentsOf: pulledEventList, in: managedObjectContext)
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
            if (!showBin) {
                HStack {
                    Text(dateString)
                        .bold()
                        .font(.system(size: 24.0))
                        .shadow(radius: Constants.BigShadowRadius)
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
                        showBin.toggle()
                    }) {
                        Image(self.taskStore.taskList.count(binned: true) == 0 ? "Dump" : "Dump Colour")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Constants.BigButtonWidth, height: Constants.BigButtonHeight)
                    }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.BigButtonLeadingPadding)
                    Button(action: {
                        loadTaskList()
                    }) {
                        Image(isPulling ? "Sync" : "Sync Colour")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .shadow(radius: Constants.ShadowRadius)
                            .rotationEffect(Angle(degrees: isPulling ? 360 : 0.0))
                            .animation(isPulling ? foreverAnimation : .default)
                            .frame(width: Constants.BigButtonWidth, height: Constants.BigButtonHeight)
                    }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.BigButtonLeadingPadding).disabled(isPulling)
                }
            } else {
                HStack {
                    Text("Bin")
                        .bold()
                        .font(.system(size: 24.0))
                        .shadow(radius: Constants.BigShadowRadius)
                    Spacer()
                }
            }
            if (self.taskStore.taskList.count(binned: false) == 0 && !showBin) {
                Button(action: {
                    self.taskStore.taskList.append(contentsOf: [EventData(id: UUID().description, text: "New task", date: taskStore.date)], in: managedObjectContext)
                }) {
                    Image("Unicorn").resizable().aspectRatio(contentMode: .fit).shadow(radius: Constants.BigShadowRadius)
                }.buttonStyle(PlainButtonStyle())
            } else {
                ScrollView(showsIndicators: taskStore.taskList.count(binned: showBin) > 8) {
                    VStack {
                        ForEach(self.taskStore.taskList.items) { task in
                            TaskView(task: task, showBin: $showBin)
                        }
                        if (!showBin) {
                            HStack {
                                Spacer()
                                Button(action: {
                                    self.taskStore.taskList.append(contentsOf: [EventData(id: UUID().description, text: "New task", date: taskStore.date)], in: managedObjectContext)
                                }) {
                                    Image("Add Colour")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: Constants.ButtonWidth, height: Constants.ButtonHeight)
                                        .shadow(radius: Constants.ShadowRadius)
                                }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.ButtonLeadingPadding)
                            }
                        }
                    }
                }
            }
            Spacer()
            if (!showBin) {
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
                            .shadow(radius: Constants.BigShadowRadius)
                    }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.BigButtonLeadingPadding).disabled(self.taskStore.taskList.isEmpty)
                    Button(action: {}) {
                        Image("Send")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Constants.BigButtonWidth, height: Constants.BigButtonHeight)
                            .shadow(radius: Constants.BigShadowRadius)
                    }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.BigButtonLeadingPadding).disabled(true)
                }
            }
        }.onAppear {
            refreshDateString()
            if (UserDefaults.standard.bool(forKey: "Active Pull")) {
                loadTaskList()
            }
        }
    }
}
