//
//  Workout.swift
//  NutriCore
//
//  Created by Mukunth Parthasarathy on 25/03/2026.
//

import Foundation

enum WorkoutIntensity {
    case low
    case moderate
    case high
}

struct Workout {
    let name: String
    let intensity: WorkoutIntensity
    let tags: [String]
    let restrictedConditions: [HealthCondition]
}
