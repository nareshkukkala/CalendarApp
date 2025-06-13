import SwiftUI
import SwiftData
import UserNotifications

struct EventFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) var modelContext

    var existingEvent: Event? = nil

    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var type: EventType = .task
    @State private var description: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Event Title", text: $title)
                DatePicker("Date", selection: $date, displayedComponents: .date)

                Picker("Type", selection: $type) {
                    ForEach(EventType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }

                TextField("Description", text: $description)
            }
            .navigationTitle(existingEvent == nil ? "Add Event" : "Edit Event")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    let event = existingEvent ?? Event(title: title, date: date, type: type, eventDescription: description)

                    event.title = title
                    event.date = date
                    event.type = type
                    event.eventDescription = description

                    if existingEvent == nil {
                        modelContext.insert(event)
                    }

                    try? modelContext.save()
                    scheduleNotification(for: event)
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .onAppear {
                if let event = existingEvent {
                    title = event.title
                    date = event.date
                    type = event.type
                    description = event.eventDescription ?? ""
                }
            }
        }
    }

    func scheduleNotification(for event: Event) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder: \(event.title)"
        content.body = "You have a \(event.type.displayName.lowercased()) today."
        content.sound = .default

        let triggerDate = Calendar.current.date(byAdding: .minute, value: -15, to: event.date) ?? event.date
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: event.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}

