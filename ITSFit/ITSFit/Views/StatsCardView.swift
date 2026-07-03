import SwiftUI

struct StatsCardView: View {
    let completedToday: Int
    let caloriesToday: Int

    var body: some View {
        HStack(spacing: 16) {
            StatTile(
                icon: "checkmark.circle.fill",
                value: "\(completedToday)",
                label: "Completed",
                color: .green
            )

            StatTile(
                icon: "flame.fill",
                value: "\(caloriesToday)",
                label: "Calories",
                color: .orange
            )

            StatTile(
                icon: "calendar",
                value: dayOfWeek(),
                label: "Today",
                color: .blue
            )
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func dayOfWeek() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: Date())
    }
}

struct StatTile: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
}
