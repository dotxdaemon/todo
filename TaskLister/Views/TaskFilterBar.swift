import SwiftUI

struct TaskFilterBar: View {
    @Binding var selection: TaskFilter

    var body: some View {
        Picker("Filter", selection: $selection) {
            ForEach(TaskFilter.allCases) { filter in
                Text(filter.displayName).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("Task filter")
    }
}

struct TaskFilterBar_Previews: PreviewProvider {
    static var previews: some View {
        TaskFilterBar(selection: .constant(.all))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
