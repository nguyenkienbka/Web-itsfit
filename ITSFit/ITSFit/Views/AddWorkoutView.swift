import SwiftUI

struct AddWorkoutView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var category: WorkoutCategory = .cardio
    @State private var duration = 30
    @State private var calories = 200

    let onAdd: (Workout) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Workout Info") {
                    TextField("Name", text: $name)

                    Picker("Category", selection: $category) {
                        ForEach(WorkoutCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                }

                Section("Details") {
                    Stepper("Duration: \(duration) min", value: $duration, in: 5...180, step: 5)
                    Stepper("Calories: \(calories) kcal", value: $calories, in: 50...1000, step: 25)
                }

                Section {
                    Button(action: save) {
                        HStack {
                            Spacer()
                            Text("Add Workout")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("New Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func save() {
        let workout = Workout(
            name: name.trimmingCharacters(in: .whitespaces),
            category: category,
            duration: duration,
            calories: calories
        )
        onAdd(workout)
        dismiss()
    }
}
