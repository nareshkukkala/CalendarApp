import SwiftUI

struct EventListView: View {
    @Environment(\.modelContext) var modelContext
    var events: [Event]
    @ObservedObject var viewModel: CalendarViewModel
    @State private var searchText: String = ""
    @State private var selectedType: EventType? = nil

    var filteredEvents: [Event] {
        events.filter { event in
            let matchesSearch = searchText.isEmpty ||
                event.title.lowercased().contains(searchText.lowercased()) ||
                (event.eventDescription?.lowercased().contains(searchText.lowercased()) ?? false)

            let matchesType = selectedType == nil || event.type == selectedType

            return matchesSearch && matchesType
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            TextField("Search Events", text: $searchText)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Button(action: { selectedType = nil }) {
                        Text("All")
                            .padding()
                            .background(selectedType == nil ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedType == nil ? .white : .primary)
                            .cornerRadius(8)
                    }

                    ForEach(EventType.allCases, id: \.self) { type in
                        Button(action: {
                            selectedType = type
                        }) {
                            Text(type.displayName)
                                .padding()
                                .background(selectedType == type ? type.color : Color.gray.opacity(0.2))
                                .foregroundColor(selectedType == type ? .white : .primary)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
            }

            List {
                ForEach(filteredEvents) { event in
                    HStack {
                        Image(systemName: event.type.icon)
                            .foregroundColor(event.type.color)
                        VStack(alignment: .leading) {
                            Text(event.title)
                                .font(.headline)
                            if let desc = event.eventDescription {
                                Text(desc)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Text(event.type.displayName)
                            .font(.caption)
                            .foregroundColor(event.type.color)
                    }
                    .onLongPressGesture {
                        viewModel.eventToReschedule = event
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        modelContext.delete(filteredEvents[index])
                    }
                    try? modelContext.save()
                }
            }
        }
    }
}