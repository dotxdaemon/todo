import Foundation
import SwiftUI

@MainActor
final class TaskStore: ObservableObject {
    @Published private(set) var tasks: [Task] = []

    private let saveURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(fileName: String = "tasks.json", inMemory: Bool = false) {
        let directory: URL
        if inMemory {
            directory = FileManager.default.temporaryDirectory
        } else {
            directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory
        }
        self.saveURL = directory.appendingPathComponent(fileName)
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        load()
    }

    var upcomingTasks: [Task] {
        tasks.filter { !$0.isCompleted }
    }

    var completedTasks: [Task] {
        tasks.filter { $0.isCompleted }
    }

    func add(_ task: Task) {
        tasks.append(task)
        persist()
    }

    func update(_ task: Task) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index] = task
        persist()
    }

    func toggleCompletion(for task: Task) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isCompleted.toggle()
        persist()
    }

    func delete(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        persist()
    }

    func delete(_ tasksToDelete: [Task]) {
        let ids = Set(tasksToDelete.map(\.id))
        tasks.removeAll { ids.contains($0.id) }
        persist()
    }

    func move(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
        persist()
    }

    private func load() {
        do {
            let data = try Data(contentsOf: saveURL)
            tasks = try decoder.decode([Task].self, from: data)
        } catch {
            if FileManager.default.fileExists(atPath: saveURL.path) {
                print("Failed to load tasks: \(error)")
            } else {
                tasks = Task.sampleData
                persist()
            }
        }
    }

    private func persist() {
        do {
            let data = try encoder.encode(tasks)
            try data.write(to: saveURL, options: [.atomic])
        } catch {
            print("Failed to save tasks: \(error)")
        }
    }
}
