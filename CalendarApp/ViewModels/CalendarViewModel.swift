import Foundation
import SwiftUI
import SwiftData

class CalendarViewModel: ObservableObject {
    @Published var currentDate: Date = Date()
    @Published var viewType: ViewType = .monthly
    @Published var selectedDate: Date = Date()
    @Published var eventToReschedule: Event? = nil

    enum ViewType {
        case weekly, monthly
    }

    private let calendar = Calendar.current

    func visibleDates() -> [Date] {
        switch viewType {
        case .monthly:
            return generateDatesForMonth()
        case .weekly:
            return generateDatesForWeek()
        }
    }

    private func generateDatesForMonth() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate) else { return [] }
        var dates: [Date] = []
        var current = monthInterval.start
        while current < monthInterval.end {
            dates.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return dates
    }

    private func generateDatesForWeek() -> [Date] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: selectedDate) else { return [] }
        var dates: [Date] = []
        var current = weekInterval.start
        while current < weekInterval.end {
            dates.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return dates
    }

    func rescheduleEvent(to newDate: Date, in context: ModelContext) {
        guard let event = eventToReschedule else { return }
        event.date = newDate
        try? context.save()
        eventToReschedule = nil
    }

    func goToNext() {
        switch viewType {
        case .monthly:
            if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentDate) {
                currentDate = nextMonth
            }
        case .weekly:
            if let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) {
                selectedDate = nextWeek
            }
        }
    }

    func goToPrevious() {
        switch viewType {
        case .monthly:
            if let prevMonth = calendar.date(byAdding: .month, value: -1, to: currentDate) {
                currentDate = prevMonth
            }
        case .weekly:
            if let prevWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) {
                selectedDate = prevWeek
            }
        }
    }

    func selectDate(_ date: Date) {
        selectedDate = date
        if viewType == .monthly {
            currentDate = date
        }
    }

    func events(for allEvents: [Event]) -> [Event] {
        allEvents.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
}
