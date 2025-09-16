import SwiftUI

@main
struct TaskListerApp: App {
    @StateObject private var store = TaskStore()

    var body: some Scene {
        WindowGroup {
            TaskListView()
                .environmentObject(store)
        }
    }
}
