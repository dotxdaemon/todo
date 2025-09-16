import Foundation

enum TaskPriority: String, CaseIterable, Codable, Identifiable {
    case low
    case medium
    case high

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
}

struct Task: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var notes: String = ""
    var dueDate: Date?
    var isCompleted: Bool = false
    var priority: TaskPriority = .medium
    var createdAt: Date = Date()

    var isOverdue: Bool {
        guard let dueDate else { return false }
        return !isCompleted && dueDate < Calendar.current.startOfDay(for: Date())
    }

    var isDueToday: Bool {
        guard let dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }
}

extension Task {
    static let sampleData: [Task] = [
        Task(title: "Plan the week", notes: "Outline the top priorities for work and home.", dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()), priority: .high),
        Task(title: "Pick up groceries", notes: "Milk, eggs, spinach, oatmeal.", dueDate: Date(), priority: .medium),
        Task(title: "Schedule dentist appointment", notes: "Call Dr. Patel's office.", dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()), priority: .low),
        Task(title: "Read 20 pages", notes: "Continue reading the productivity book.", dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()), priority: .medium)
    ]
}
