import SwiftUI
import Combine

struct ProfileView: View {
    @ObservedObject private var profileManager = ProfileManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var newMedication: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.10),
                        Color.purple.opacity(0.06),
                        Color(.systemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Profile")
                                .font(.system(size: 34, weight: .bold))

                            Text("Personalize your health, calories, and workouts")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "paintbrush.fill")
                                    .foregroundColor(.blue)
                                Text("Appearance")
                                    .font(.headline)
                            }

                            Picker("Theme", selection: $themeManager.selectedTheme) {
                                ForEach(AppTheme.allCases, id: \.self) { theme in
                                    Text(theme.rawValue).tag(theme)
                                }
                            }
                            .pickerStyle(.segmented)

                            Text("Instantly switch between light and dark themes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .profileCard()

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "figure.walk")
                                    .foregroundColor(.blue)
                                Text("Health & Fitness")
                                    .font(.headline)
                            }

                            NavigationLink {
                                WorkoutRecommendationView()
                            } label: {
                                HStack {
                                    Image(systemName: "figure.walk")
                                        .foregroundColor(.blue)
                                    Text("Recommended Workouts")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                        .profileCard()

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "person.text.rectangle")
                                    .foregroundColor(.blue)
                                Text("Personal Info")
                                    .font(.headline)
                            }

                            TextField("Name", text: binding(\.name))
                                .textFieldStyle(.roundedBorder)

                            Stepper("Age: \(profileManager.profile.age)", value: binding(\.age), in: 10...100)

                            HStack {
                                Text("Height")
                                Spacer()
                                TextField("cm", value: binding(\.heightCm), format: .number)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 80)
                                    .textFieldStyle(.roundedBorder)
                            }

                            HStack {
                                Text("Weight")
                                Spacer()
                                TextField("kg", value: binding(\.weightKg), format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 80)
                                    .textFieldStyle(.roundedBorder)
                            }

                            HStack {
                                Text("Target Weight")
                                Spacer()
                                TextField("kg", value: binding(\.targetWeightKg), format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 80)
                                    .textFieldStyle(.roundedBorder)
                            }

                            Picker("Gender", selection: binding(\.gender)) {
                                ForEach(Gender.allCases, id: \.self) { gender in
                                    Text(gender.rawValue).tag(gender)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .profileCard()

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "target")
                                    .foregroundColor(.blue)
                                Text("Goals")
                                    .font(.headline)
                            }

                            Picker("Activity Level", selection: binding(\.activityLevel)) {
                                ForEach(ActivityLevel.allCases, id: \.self) { level in
                                    Text(level.rawValue).tag(level)
                                }
                            }

                            Picker("Goal", selection: binding(\.goalType)) {
                                ForEach(GoalType.allCases, id: \.self) { goal in
                                    Text(goal.rawValue).tag(goal)
                                }
                            }
                            .pickerStyle(.segmented)

                            HStack {
                                Text("Daily Calorie Goal")
                                Spacer()
                                Text("\(profileManager.profile.dailyCalorieGoal) kcal")
                            }

                            Slider(
                                value: Binding(
                                    get: { Double(profileManager.profile.dailyCalorieGoal) },
                                    set: { newValue in
                                        profileManager.update { profile in
                                            profile.dailyCalorieGoal = Int(newValue)
                                        }
                                    }
                                ),
                                in: 1200...3500,
                                step: 50
                            )

                            Text("Based on your profile")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Button("Auto Set Goal") {
                                let recommended = profileManager.calculateRecommendedCalories()
                                profileManager.update { profile in
                                    profile.dailyCalorieGoal = recommended
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .profileCard()

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "heart.text.square.fill")
                                    .foregroundColor(.blue)
                                Text("Health & Safety")
                                    .font(.headline)
                            }

                            Toggle("Doctor Cleared For Exercise", isOn: binding(\.doctorClearedForExercise))

                            Text("Health Conditions")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 10) {
                                ForEach(HealthCondition.allCases, id: \.self) { condition in
                                    Button {
                                        toggleCondition(condition)
                                    } label: {
                                        Text(condition.rawValue)
                                            .font(.caption)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(
                                                profileManager.profile.healthConditions.contains(condition)
                                                ? Color.blue.opacity(0.2)
                                                : Color(.systemGray5)
                                            )
                                            .foregroundColor(.primary)
                                            .cornerRadius(10)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            Picker("Workout Preference", selection: binding(\.workoutPreference)) {
                                ForEach(WorkoutPreference.allCases, id: \.self) { preference in
                                    Text(preference.rawValue).tag(preference)
                                }
                            }
                            .pickerStyle(.segmented)

                            Text("Medications")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            HStack {
                                TextField("Add medication", text: $newMedication)
                                    .textFieldStyle(.roundedBorder)

                                Button("Add") {
                                    addMedication()
                                }
                                .buttonStyle(.borderedProminent)
                            }

                            if !profileManager.profile.medications.isEmpty {
                                ForEach(profileManager.profile.medications, id: \.self) { medication in
                                    HStack {
                                        Text(medication)
                                        Spacer()
                                    }
                                    .font(.caption)
                                    .padding(.vertical, 4)
                                }
                            }

                            Text("Injury / Notes")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            TextEditor(
                                text: Binding(
                                    get: { profileManager.profile.injuryNotes },
                                    set: { newValue in
                                        profileManager.update { profile in
                                            profile.injuryNotes = newValue
                                        }
                                    }
                                )
                            )
                            .frame(height: 100)
                            .padding(4)
                            .background(Color(.systemBackground))
                            .cornerRadius(10)

                            Text("Not medical advice. Stop exercise if you feel pain, dizziness, or shortness of breath.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .profileCard()

                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.blue)
                                Text("Summary")
                                    .font(.headline)
                            }

                            summaryRow(title: "Current Weight", value: String(format: "%.1f kg", profileManager.profile.weightKg))
                            summaryRow(title: "Target Weight", value: String(format: "%.1f kg", profileManager.profile.targetWeightKg))
                            summaryRow(title: "Daily Goal", value: "\(profileManager.profile.dailyCalorieGoal) kcal")
                            summaryRow(title: "Goal Type", value: profileManager.profile.goalType.rawValue)
                            summaryRow(title: "Doctor Cleared", value: profileManager.profile.doctorClearedForExercise ? "Yes" : "No")
                            summaryRow(title: "Workout Preference", value: profileManager.profile.workoutPreference.rawValue)
                            summaryRow(title: "Conditions", value: profileManager.profile.healthConditions.isEmpty ? "None" : profileManager.profile.healthConditions.map(\.rawValue).joined(separator: ", "))
                        }
                        .profileCard()

                        NavigationLink {
                            WorkoutRecommendationView()
                        } label: {
                            HStack {
                                Image(systemName: "figure.walk")
                                    .foregroundColor(.blue)
                                Text("Open Recommended Workouts")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                            .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical)
                }
            }
        }
    }

    private func binding<Value>(_ keyPath: WritableKeyPath<UserProfile, Value>) -> Binding<Value> {
        Binding(
            get: { profileManager.profile[keyPath: keyPath] },
            set: { newValue in
                profileManager.update { $0[keyPath: keyPath] = newValue }
            }
        )
    }

    private func toggleCondition(_ condition: HealthCondition) {
        profileManager.update { profile in
            if profile.healthConditions.contains(condition) {
                profile.healthConditions.removeAll { $0 == condition }
            } else {
                profile.healthConditions.append(condition)
            }
        }
    }

    private func addMedication() {
        let trimmed = newMedication.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        profileManager.update { profile in
            profile.medications.append(trimmed)
        }

        newMedication = ""
    }

    @ViewBuilder
    private func summaryRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

private extension View {
    func profileCard() -> some View {
        self
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            .padding(.horizontal)
    }
}

enum Gender: String, CaseIterable, Codable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
}

enum ActivityLevel: String, CaseIterable, Codable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
}

enum GoalType: String, CaseIterable, Codable {
    case loseWeight = "Lose"
    case maintain = "Maintain"
    case gainWeight = "Gain"
}

enum HealthCondition: String, CaseIterable, Codable {
    case diabetes = "Diabetes"
    case highBloodPressure = "High Blood Pressure"
    case asthma = "Asthma"
    case kneePain = "Knee Pain"
    case backPain = "Back Pain"
    case heartCondition = "Heart Condition"
    case pregnancy = "Pregnancy"
    case jointPain = "Joint Pain"
}

enum WorkoutPreference: String, CaseIterable, Codable {
    case lowImpact = "Low Impact"
    case moderate = "Moderate"
    case gentle = "Gentle"
}

struct UserProfile: Codable {
    var name: String = ""
    var age: Int = 20
    var heightCm: Int = 170
    var weightKg: Double = 70
    var targetWeightKg: Double = 68
    var gender: Gender = .other
    var activityLevel: ActivityLevel = .moderate
    var goalType: GoalType = .maintain
    var dailyCalorieGoal: Int = 1800
    var healthConditions: [HealthCondition] = []
    var medications: [String] = []
    var injuryNotes: String = ""
    var doctorClearedForExercise: Bool = false
    var workoutPreference: WorkoutPreference = .lowImpact
}
