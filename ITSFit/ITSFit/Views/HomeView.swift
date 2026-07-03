import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    @State private var showingAddWorkout = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Stats Header
                    StatsCardView(
                        completedToday: viewModel.completedToday,
                        caloriesToday: viewModel.totalCaloriesToday
                    )
                    .padding(.horizontal)

                    // Category Filter
                    CategoryFilterView(selectedCategory: $viewModel.selectedCategory)

                    // Workout List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Workouts")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        ForEach(viewModel.filteredWorkouts) { workout in
                            WorkoutCardView(workout: workout) {
                                viewModel.toggleCompletion(workout)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("ITSFit")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddWorkout = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddWorkout) {
                AddWorkoutView { newWorkout in
                    viewModel.addWorkout(newWorkout)
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}
