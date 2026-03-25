//
//  WorkoutEngine.swift
//  NutriCore
//
//  Created by Mukunth Parthasarathy on 25/03/2026.
//

import Foundation

final class WorkoutEngine {

    static let shared = WorkoutEngine()

    private init() {}

    let allWorkouts: [Workout] = [
        Workout(name: "Walking", intensity: .low, tags: ["cardio"], restrictedConditions: []),
        Workout(name: "Cycling", intensity: .moderate, tags: ["cardio"], restrictedConditions: []),
        Workout(name: "Swimming", intensity: .moderate, tags: ["low-impact"], restrictedConditions: []),
        Workout(name: "Yoga", intensity: .low, tags: ["flexibility"], restrictedConditions: []),
        Workout(name: "Strength Training", intensity: .moderate, tags: ["strength"], restrictedConditions: [.heartCondition]),
        Workout(name: "HIIT", intensity: .high, tags: ["cardio"], restrictedConditions: [.heartCondition, .highBloodPressure]),
        Workout(name: "Jump Rope", intensity: .high, tags: ["impact"], restrictedConditions: [.kneePain, .jointPain]),
        Workout(name: "Stretching", intensity: .low, tags: ["mobility"], restrictedConditions: [])
    ]

    func recommendedWorkouts(for profile: UserProfile) -> [Workout] {
        allWorkouts.filter { workout in
            // Remove unsafe workouts
            for condition in profile.healthConditions {
                if workout.restrictedConditions.contains(condition) {
                    return false
                }
            }

            // Respect workout preference
            switch profile.workoutPreference {
            case .gentle:
                return workout.intensity == .low
            case .lowImpact:
                return workout.intensity != .high
            case .moderate:
                return true
            }
        }
    }

    func avoidedWorkouts(for profile: UserProfile) -> [(workout: Workout, reason: String)] {
        allWorkouts.compactMap { workout in
            for condition in profile.healthConditions {
                if workout.restrictedConditions.contains(condition) {
                    return (workout, "Avoided due to \(condition.rawValue)")
                }
            }

            switch profile.workoutPreference {
            case .gentle:
                if workout.intensity != .low {
                    return (workout, "Avoided because it may be too intense for a gentle preference")
                }
            case .lowImpact:
                if workout.intensity == .high {
                    return (workout, "Avoided because it is high intensity")
                }
            case .moderate:
                break
            }

            return nil
        }
    }
}
