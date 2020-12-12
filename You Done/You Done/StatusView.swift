//
//  StatusView.swift
//  You Done
//
//  Created by Piotr Galar on 08/12/2020.
//

import SwiftUI

struct StatusView: View {
    @EnvironmentObject var integrationStore: IntegrationStore
    @ObservedObject var taskList: TaskList = TaskList()

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
    
    @State private var isPulling = 0
    private func loadTaskList(force: Bool = true) {
        if (taskList.isEmpty || force) {
            integrationStore.all(forState: .installed).forEach { integration in
                isPulling += 1
                integration.pull(date: date).subscribe(
                    onNext: { pulledTaskList in
                        taskList.append(contentsOf: pulledTaskList)
                        isPulling -= 1
                    },
                    onError: { error in
                        print(error)
                        isPulling -= 1
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
                        Image(isPulling == 0 ? "Sync Colour" : "Sync")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Constants.BigButtonWidth, height: Constants.BigButtonHeight)
                    }.buttonStyle(PlainButtonStyle()).disabled(isPulling != 0).padding(.leading, Constants.BigButtonLeadingPadding)
                }
                ScrollView(showsIndicators: false) {
                    VStack {
                        ForEach(self.taskList.taskList) { task in
                            TaskView(task: task)
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
                    Image("File Colour")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.BigButtonWidth, height: Constants.BigButtonHeight)
                }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.BigButtonLeadingPadding)
                Button(action: { print("Send") }) {
                    Image("Send Colour")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.BigButtonWidth, height: Constants.BigButtonHeight)
                }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.BigButtonLeadingPadding)
            }
            
        }.onAppear { loadTaskList(force: false) }
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatusView()
    }
}
