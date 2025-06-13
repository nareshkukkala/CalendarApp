import Foundation
import SwiftUICore
import SwiftData

@Model
final class Event {
    @Attribute(.unique) var id: UUID
    var title: String
    var date: Date
    var type: EventType
    var eventDescription: String?

    init(id: UUID = UUID(), title: String, date: Date, type: EventType, eventDescription: String?) {
        self.id = id
        self.title = title
        self.date = date
        self.type = type
        self.eventDescription = eventDescription
    }
}

enum EventType: String, Codable, CaseIterable {
    case task, meeting, birthday, leave, calendar

    var displayName: String {
        switch self {
        case .task: return "Task"
        case .meeting: return "Meeting"
        case .birthday: return "Birthday"
        case .leave: return "Leave"
        case .calendar: return "Event"
        }
    }

    var icon: String {
        switch self {
        case .task: return "checkmark.circle"
        case .meeting: return "person.3.sequence"
        case .birthday: return "gift"
        case .leave: return "airplane"
        case .calendar: return "calendar"
        }
    }

    var color: Color {
        switch self {
        case .task: return .blue
        case .meeting: return .purple
        case .birthday: return .orange
        case .leave: return .green
        case .calendar: return .gray
        }
    }
}
