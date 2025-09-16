import SwiftUI

struct TaskRowView: View {
    let task: Task
    var onToggleCompletion: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Button(action: onToggleCompletion) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(task.isCompleted ? Color.accentColor : Color.secondary)
                    .accessibilityLabel(task.isCompleted ? "Mark task as incomplete" : "Mark task as complete")
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.headline)
                    .foregroundStyle(task.isCompleted ? Color.secondary : Color.primary)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .animation(.default, value: task.isCompleted)

                if let dueDate = task.dueDate {
                    Label(DateFormatterProvider.taskDueDate.string(from: dueDate), systemImage: task.isOverdue ? "calendar.badge.exclamationmark" : "calendar")
                        .font(.caption)
                        .foregroundStyle(task.isOverdue ? Color.red : Color.secondary)
                        .strikethrough(task.isCompleted, color: .secondary)
                        .animation(.default, value: task.isCompleted)
                }

                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }

            Spacer()

            Text(task.priority.displayName)
                .font(.caption.weight(.semibold))
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(priorityColor.opacity(0.15))
                .foregroundColor(priorityColor)
                .clipShape(Capsule())
                .accessibilityLabel("Priority \(task.priority.displayName)")
        }
        .padding(.vertical, 8)
    }

    private var priorityColor: Color {
        switch task.priority {
        case .low:
            return Color.blue
        case .medium:
            return Color.orange
        case .high:
            return Color.red
        }
    }
}

struct TaskRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TaskRowView(task: Task.sampleData[0], onToggleCompletion: {})
            TaskRowView(task: Task.sampleData[1], onToggleCompletion: {})
                .preferredColorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
