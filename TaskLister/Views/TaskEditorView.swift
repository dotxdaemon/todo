import SwiftUI

struct TaskEditorView: View {
    @Environment(\.dismiss) private var dismiss

    private let task: Task?
    private let onSave: (Task) -> Void

    @State private var title: String
    @State private var notes: String
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var priority: TaskPriority
    @State private var isCompleted: Bool
    @FocusState private var focusedField: Field?

    init(task: Task? = nil, onSave: @escaping (Task) -> Void) {
        self.task = task
        self.onSave = onSave

        _title = State(initialValue: task?.title ?? "")
        _notes = State(initialValue: task?.notes ?? "")
        let initialDueDate = task?.dueDate ?? Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        _dueDate = State(initialValue: initialDueDate)
        _hasDueDate = State(initialValue: task?.dueDate != nil)
        _priority = State(initialValue: task?.priority ?? .medium)
        _isCompleted = State(initialValue: task?.isCompleted ?? false)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Details")) {
                    TextField("Title", text: $title)
                        .focused($focusedField, equals: .title)
                        .textInputAutocapitalization(.sentences)
                        .disableAutocorrection(false)

                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases) { priority in
                            Text(priority.displayName).tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Due Date")) {
                    Toggle("Set due date", isOn: $hasDueDate.animation())
                    if hasDueDate {
                        DatePicker("", selection: $dueDate, displayedComponents: [.date])
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                    }
                }

                Section(header: Text("Notes")) {
                    ZStack(alignment: .topLeading) {
                        if notes.isEmpty {
                            Text("Add any extra context...")
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                                .allowsHitTesting(false)
                        }
                        TextEditor(text: $notes)
                            .frame(minHeight: 120)
                            .focused($focusedField, equals: .notes)
                    }
                }

                if task != nil {
                    Section {
                        Toggle("Mark as completed", isOn: $isCompleted)
                    }
                }
            }
            .navigationTitle(task == nil ? "New Task" : "Edit Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveTask() }
                        .disabled(!canSave)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if task == nil {
                        focusedField = .title
                    }
                }
            }
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func saveTask() {
        var updatedTask = task ?? Task(title: title)
        updatedTask.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedTask.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedTask.dueDate = hasDueDate ? Calendar.current.startOfDay(for: dueDate) : nil
        updatedTask.priority = priority
        if task != nil {
            updatedTask.isCompleted = isCompleted
        } else {
            updatedTask.isCompleted = false
        }
        onSave(updatedTask)
        dismiss()
    }

    private enum Field {
        case title
        case notes
    }
}

struct TaskEditorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TaskEditorView(task: Task.sampleData.first!) { _ in }
        }
        NavigationStack {
            TaskEditorView { _ in }
        }
    }
}
