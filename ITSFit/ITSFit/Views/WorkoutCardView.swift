import SwiftUI

struct WorkoutCardView: View {
    let workout: Workout
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            // Category Icon
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.15))
                    .frame(width: 52, height: 52)

                Image(systemName: workout.category.icon)
                    .font(.title2)
                    .foregroundStyle(categoryColor)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.headline)
                    .strikethrough(workout.isCompleted, color: .secondary)
                    .foregroundStyle(workout.isCompleted ? .secondary : .primary)

                HStack(spacing: 12) {
                    Label("\(workout.duration) min", systemImage: "clock")
                    Label("\(workout.calories) kcal", systemImage: "flame")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            // Completion Toggle
            Button(action: onToggle) {
                Image(systemName: workout.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(workout.isCompleted ? .green : .secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .opacity(workout.isCompleted ? 0.75 : 1.0)
    }

    private var categoryColor: Color {
        switch workout.category.color {
        case "red": return .red
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "green": return .green
        case "cyan": return .cyan
        default: return .blue
        }
    }
}
