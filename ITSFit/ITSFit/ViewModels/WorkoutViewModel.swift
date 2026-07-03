import Foundation
import Combine

class WorkoutViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var selectedCategory: WorkoutCategory? = nil

    private let saveKey = "saved_workouts"

    init() {
        loadWorkouts()
        if workouts.isEmpty {
            workouts = Self.sampleWorkouts
        }
    }

    var filteredWorkouts: [Workout] {
        guard let category = selectedCategory else { return workouts }
        return workouts.filter { $0.category == category }
    }

    var totalCaloriesToday: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return workouts
            .filter { $0.isCompleted && Calendar.current.startOfDay(for: $0.date) == today }
            .reduce(0) { $0 + $1.calories }
    }

    var completedToday: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return workouts
            .filter { $0.isCompleted && Calendar.current.startOfDay(for: $0.date) == today }
            .count
    }

    func toggleCompletion(_ workout: Workout) {
        if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
            workouts[index].isCompleted.toggle()
            saveWorkouts()
        }
    }

    func addWorkout(_ workout: Workout) {
        workouts.insert(workout, at: 0)
        saveWorkouts()
    }

    func deleteWorkout(at offsets: IndexSet) {
        workouts.remove(atOffsets: offsets)
        saveWorkouts()
    }

    private func saveWorkouts() {
        if let encoded = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    private func loadWorkouts() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Workout].self, from: data) {
            workouts = decoded
        }
    }

    static let sampleWorkouts: [Workout] = [
        Workout(name: "Morning Run", category: .running, duration: 30, calories: 300),
        Workout(name: "Full Body Strength", category: .strength, duration: 45, calories: 400),
        Workout(name: "HIIT Blast", category: .hiit, duration: 20, calories: 350),
        Workout(name: "Evening Yoga", category: .yoga, duration: 60, calories: 200),
        Workout(name: "Cycling Session", category: .cycling, duration: 40, calories: 320),
        Workout(name: "Cardio Dance", category: .cardio, duration: 35, calories: 280),
    ]
}
