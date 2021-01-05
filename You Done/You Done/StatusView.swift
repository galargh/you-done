//
//  StatusView.swift
//  You Done
//
//  Created by Piotr Galar on 08/12/2020.
//

import SwiftUI

struct StatusView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var taskStore: TaskStore
    
    @Binding var showBin: Bool
    
    @State private var showDatePicker = false
        
    private var foreverAnimation: Animation {
        Animation.linear(duration: 4.0)
            .repeatForever(autoreverses: false)
    }

    var body: some View {
        VStack {
            if (!showBin) {
                HStack {
                    Text(taskStore.getDateString())
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
                                set: { date in self.taskStore.setDate(date); self.showDatePicker = false }
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
                            .shadow(radius: Constants.BigShadowRadius)
                            .frame(width: Constants.BigButtonWidth, height: Constants.BigButtonHeight)
                    }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.BigButtonLeadingPadding).disabled(self.taskStore.taskList.count(binned: true) == 0)
                    Button(action: {
                        taskStore.pull(true)
                    }) {
                        Image(taskStore.isPulling ? "Sync" : "Sync Colour")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .shadow(radius: Constants.BigShadowRadius)
                            .rotationEffect(Angle(degrees: taskStore.isPulling ? 360 : 0.0))
                            .animation(taskStore.isPulling ? foreverAnimation : .default)
                            .frame(width: Constants.BigButtonWidth, height: Constants.BigButtonHeight)
                    }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.BigButtonLeadingPadding).disabled(taskStore.isPulling)
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
                    self.taskStore.taskList.append(contentsOf: [EventData(text: "New task", date: taskStore.date)], in: managedObjectContext)
                }) {
                    Image("Unicorn").resizable().aspectRatio(contentMode: .fit).shadow(radius: Constants.BigShadowRadius)
                }.buttonStyle(PlainButtonStyle())
            } else {
                ScrollView {
                    VStack {
                        ForEach(self.taskStore.taskList.items) { task in
                            TaskView(task: task, showBin: $showBin)
                        }
                        if (!showBin) {
                            HStack {
                                Spacer()
                                Button(action: {
                                    self.taskStore.taskList.append(contentsOf: [EventData(text: "New task", date: taskStore.date)], in: managedObjectContext)
                                }) {
                                    Image("Add Colour")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .shadow(radius: Constants.ShadowRadius)
                                        .frame(width: Constants.ButtonWidth, height: Constants.ButtonHeight)
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
                        pasteBoard.writeObjects([self.taskStore.taskList.toString(title: self.taskStore.getDateString()) as NSString])
                    }) {
                        Image(self.taskStore.taskList.isEmpty ? "File" : "File Colour")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .shadow(radius: Constants.BigShadowRadius)
                            .frame(width: Constants.BigButtonWidth, height: Constants.BigButtonHeight)
                    }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.BigButtonLeadingPadding).disabled(self.taskStore.taskList.isEmpty)
                    Button(action: {}) {
                        Image("Send")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .shadow(radius: Constants.BigShadowRadius)
                            .frame(width: Constants.BigButtonWidth, height: Constants.BigButtonHeight)
                    }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.BigButtonLeadingPadding).disabled(true)
                }
            }
        }
    }
}
