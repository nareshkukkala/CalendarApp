import Foundation
import SwiftData

struct MockEventSeeder {
    static func preload(into context: ModelContext) {
        let existing = try? context.fetch(FetchDescriptor<Event>())
        if existing?.isEmpty == false { return }

        let calendar = Calendar.current
        let today = Date()
        let titles = ["Design Review", "Sprint Planning", "Team Lunch", "Birthday", "Annual Leave", "Feature Release", "One-on-One", "Holiday"]
        let types: [EventType] = [.meeting, .task, .calendar, .birthday, .leave]

        for i in 0..<500 {
            let offset = Int.random(in: -90...90)
            guard let eventDate = calendar.date(byAdding: .day, value: offset, to: today) else { continue }

            let event = Event(
                title: titles.randomElement()!,
                date: eventDate,
                type: types.randomElement()!,
                eventDescription: "Mock event number \(i + 1)"
            )

            context.insert(event)
        }

        try? context.save()
        print("✅ Seeded 500+ mock events into database.")
    }
}