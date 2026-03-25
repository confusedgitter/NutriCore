//
//  WorkoutRecommendationView.swift
//  NutriCore
//
//  Created by Mukunth Parthasarathy on 25/03/2026.
//

import SwiftUI

struct WorkoutRecommendationView: View {

    @ObservedObject private var profileManager = ProfileManager.shared

    var body: some View {
        let profile = profileManager.profile
        let workouts = WorkoutEngine.shared.recommendedWorkouts(for: profile)
        let avoided = WorkoutEngine.shared.avoidedWorkouts(for: profile)
        let todaysWorkout = workoutOfTheDay(from: workouts)

        NavigationStack {
            List {
                if let workout = todaysWorkout {
                    Section("Today's Pick") {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(workout.name)
                                .font(.headline)

                            Text("Intensity: \(intensityText(workout.intensity))")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(reason(for: workout))
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                        .padding(.vertical, 4)
                    }
                }
                Section("Recommended") {
                    ForEach(workouts, id: \.name) { workout in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(workout.name)
                                .font(.headline)

                            Text("Intensity: \(intensityText(workout.intensity))")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(reason(for: workout))
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                        .padding(.vertical, 4)
                    }
                }

                if !avoided.isEmpty {
                    Section("Avoided Workouts") {
                        ForEach(avoided, id: \.workout.name) { item in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.workout.name)
                                    .font(.headline)

                                Text("Intensity: \(intensityText(item.workout.intensity))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Text(item.reason)
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Recommended Workouts")
        }
    }

    private func intensityText(_ intensity: WorkoutIntensity) -> String {
        switch intensity {
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        }
    }
    private func reason(for workout: Workout) -> String {
        let profile = profileManager.profile

        var reasons: [String] = []

        if profile.workoutPreference == .lowImpact {
            reasons.append("Low impact match")
        }

        if profile.workoutPreference == .gentle {
            reasons.append("Gentle on body")
        }

        if profile.healthConditions.contains(.kneePain) && workout.intensity != .high {
            reasons.append("Knee-friendly")
        }

        if profile.healthConditions.contains(.backPain) {
            reasons.append("Supports mobility")
        }

        if profile.healthConditions.contains(.highBloodPressure) {
            reasons.append("Safe intensity")
        }

        if reasons.isEmpty {
            return "Good general fitness option"
        }

        return reasons.joined(separator: " • ")
    }

    private func workoutOfTheDay(from workouts: [Workout]) -> Workout? {
        guard !workouts.isEmpty else { return nil }

        let day = Calendar.current.component(.day, from: Date())
        return workouts[day % workouts.count]
    }
}
