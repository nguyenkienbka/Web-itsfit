import Foundation

struct Workout: Identifiable, Codable {
    var id = UUID()
    var name: String
    var category: WorkoutCategory
    var duration: Int // minutes
    var calories: Int
    var isCompleted: Bool = false
    var date: Date = Date()
}

enum WorkoutCategory: String, CaseIterable, Codable {
    case cardio = "Cardio"
    case strength = "Strength"
    case yoga = "Yoga"
    case hiit = "HIIT"
    case cycling = "Cycling"
    case running = "Running"

    var icon: String {
        switch self {
        case .cardio: return "heart.fill"
        case .strength: return "dumbbell.fill"
        case .yoga: return "figure.mind.and.body"
        case .hiit: return "bolt.fill"
        case .cycling: return "bicycle"
        case .running: return "figure.run"
        }
    }

    var color: String {
        switch self {
        case .cardio: return "red"
        case .strength: return "blue"
        case .yoga: return "purple"
        case .hiit: return "orange"
        case .cycling: return "green"
        case .running: return "cyan"
        }
    }
}
