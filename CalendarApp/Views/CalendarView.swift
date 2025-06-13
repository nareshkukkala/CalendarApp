import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Event.date) var events: [Event]
    @StateObject var viewModel = CalendarViewModel()
    @State private var showAddSheet = false

    var body: some View {
        VStack {
            if let reschedEvent = viewModel.eventToReschedule {
                Text("Rescheduling: \(reschedEvent.title)")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.bottom, 4)
            }

            Picker("View Type", selection: $viewModel.viewType) {
                Text("Monthly").tag(CalendarViewModel.ViewType.monthly)
                Text("Weekly").tag(CalendarViewModel.ViewType.weekly)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            HStack {
                Button(action: { viewModel.goToPrevious() }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(viewModel.viewType == .monthly ?
                     formattedMonth(viewModel.currentDate) :
                     formattedWeek(viewModel.selectedDate))
                    .font(.headline)
                Spacer()
                Button(action: { viewModel.goToNext() }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(viewModel.visibleDates(), id: \.self) { date in
                    DayCellView(
                        date: date,
                        eventCount: events.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }.count,
                        selectedDate: viewModel.selectedDate,
                        isRescheduling: viewModel.eventToReschedule != nil,
                        onDateChosen: { newDate in
                            viewModel.selectDate(newDate)
                            viewModel.rescheduleEvent(to: newDate, in: modelContext)
                        }
                    )
                    .onTapGesture {
                        viewModel.selectDate(date)
                    }
                }
            }

            
            EventListView(events: viewModel.events(for: events), viewModel: viewModel)
                .padding(.top, 8)

            Button(action: {
                showAddSheet = true
            }) {
                Label("Add Event", systemImage: "plus")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
            .sheet(isPresented: $showAddSheet) {
                EventFormView() // eventStore not needed with SwiftData
            }
        
        }
    }

    func formattedMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }

    func formattedWeek(_ date: Date) -> String {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else { return "" }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"

        return "\(formatter.string(from: weekInterval.start)) - \(formatter.string(from: weekInterval.end.addingTimeInterval(-1)))"
    }
}

