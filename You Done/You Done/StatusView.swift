//
//  StatusView.swift
//  You Done
//
//  Created by Piotr Galar on 08/12/2020.
//

import SwiftUI

struct StatusView: View {
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }

    @State private var date = Date()
    @State private var showDatePicker = false
    @State private var prevDate: Date?
    
    func dateString() -> String { dateFormatter.string(from: date) }

    var body: some View {
        VStack {
            HStack {
                Text(dateString())
                    .onTapGesture {
                        showDatePicker.toggle()
                    }
                    .popover(
                        isPresented: $showDatePicker,
                        arrowEdge: .bottom
                    ) {
                        DatePicker(dateString(), selection: $date, in: ...Date(), displayedComponents: .date).datePickerStyle(GraphicalDatePickerStyle())
                            .labelsHidden()
                    }
                    
                Spacer()
            }
            Spacer()
        }
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatusView()
    }
}
