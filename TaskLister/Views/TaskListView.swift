import SwiftUI

struct TaskListView: View {
    @EnvironmentObject private var store: TaskStore
    @State private var activeSheet: ActiveSheet?
    @State private var searchText: String = ""
    @State private var filter: TaskFilter = .all

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TaskFilterBar(selection: $filter)
                    .padding(.horizontal)
                    .padding(.top, 12)

                if filteredTasks.isEmpty {
                    Spacer(minLength: 24)
                    EmptyStateView(
                        title: "No tasks to show",
                        message: emptyStateMessage
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(filteredTasks) { task in
                            TaskRowView(task: task, onToggleCompletion: {
                                toggleCompletion(for: task)
                            })
                            .contentShape(Rectangle())
                            .onTapGesture {
                                activeSheet = .edit(task)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    toggleCompletion(for: task)
                                } label: {
                                    if task.isCompleted {
                                        Label("Mark Open", systemImage: "arrow.uturn.backward.circle")
                                    } else {
                                        Label("Complete", systemImage: "checkmark.circle")
                                    }
                                }
                                .tint(task.isCompleted ? .orange : .green)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    store.delete([task])
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .onDelete(perform: deleteTasks)
                        .onMove(perform: moveTasks)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Task Lister")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                        .disabled(!canReorder)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        activeSheet = .new
                    } label: {
                        Label("Add Task", systemImage: "plus")
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: filteredTasks)
        }
        .sheet(item: $activeSheet, content: sheetContent)
    }

    private var filteredTasks: [Task] {
        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        let filtered = store.tasks.filter { task in
            filter.allows(task: task) &&
            (trimmedQuery.isEmpty || task.title.localizedCaseInsensitiveContains(trimmedQuery) || task.notes.localizedCaseInsensitiveContains(trimmedQuery))
        }

        if canReorder {
            return filtered
        }

        return filtered.sorted { lhs, rhs in
            switch (lhs.isCompleted, rhs.isCompleted) {
            case (false, true):
                return true
            case (true, false):
                return false
            default:
                break
            }

            let lhsDate = lhs.dueDate ?? Date.distantFuture
            let rhsDate = rhs.dueDate ?? Date.distantFuture

            if lhsDate != rhsDate {
                return lhsDate < rhsDate
            }

            return lhs.createdAt < rhs.createdAt
        }
    }

    private var emptyStateMessage: String {
        switch filter {
        case .all:
            return "Add a task with the plus button to get started."
        case .today:
            return "You have nothing scheduled for today."
        case .upcoming:
            return "There are no upcoming tasks yet."
        case .completed:
            return "Complete a task to see it here."
        }
    }

    private var canReorder: Bool {
        filter == .all && searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func deleteTasks(at offsets: IndexSet) {
        let tasksToDelete = offsets.compactMap { index -> Task? in
            guard filteredTasks.indices.contains(index) else { return nil }
            return filteredTasks[index]
        }
        store.delete(tasksToDelete)
    }

    private func moveTasks(from source: IndexSet, to destination: Int) {
        guard canReorder else { return }
        store.move(from: source, to: destination)
    }

    private func toggleCompletion(for task: Task) {
        withAnimation {
            store.toggleCompletion(for: task)
        }
    }

    @ViewBuilder
    private func sheetContent(for sheet: ActiveSheet) -> some View {
        switch sheet {
        case .new:
            TaskEditorView { newTask in
                store.add(newTask)
            }
        case .edit(let task):
            TaskEditorView(task: task) { updatedTask in
                store.update(updatedTask)
            }
        }
    }
}

extension TaskListView {
    enum ActiveSheet: Identifiable {
        case new
        case edit(Task)

        var id: String {
            switch self {
            case .new:
                return "new"
            case .edit(let task):
                return task.id.uuidString
            }
        }
    }
}

enum TaskFilter: String, CaseIterable, Identifiable {
    case all
    case today
    case upcoming
    case completed

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all:
            return "All"
        case .today:
            return "Today"
        case .upcoming:
            return "Upcoming"
        case .completed:
            return "Done"
        }
    }

    func allows(task: Task) -> Bool {
        switch self {
        case .all:
            return true
        case .today:
            return task.isDueToday
        case .upcoming:
            if task.isCompleted {
                return false
            }
            guard let dueDate = task.dueDate else { return true }
            return dueDate >= Calendar.current.startOfDay(for: Date())
        case .completed:
            return task.isCompleted
        }
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView()
            .environmentObject(TaskStore(inMemory: true))
    }
}
