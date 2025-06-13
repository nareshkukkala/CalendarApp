import SwiftUI

struct DayCellView: View {
    let date: Date
    let eventCount: Int
    let selectedDate: Date
    let isRescheduling: Bool
    let onDateChosen: (Date) -> Void

    var body: some View {
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)

        //print("Rendering DayCellView for date: \(date), selectedDate: \(selectedDate), isSelected: \(isSelected)")

        VStack(spacing: 4) {
            Text("\(Calendar.current.component(.day, from: date))")
                .foregroundColor(isSelected ? .white : .primary)
                .padding(8)
                .background(isSelected ? Color.blue : Color.clear)
                .clipShape(Circle())

            if eventCount > 0 {
                Text("\(eventCount)")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            onDateChosen(date)
        }
    }
}

