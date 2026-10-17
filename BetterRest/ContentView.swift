//
//  ContentView.swift
//  BetterRest
//
//  Created by Nuray Beydullayeva on 13.10.26.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var wakeUp = ContentView.defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var bedtime = Date.now
    
    
    
   static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
                    ZStack {
                        Color(red: 0.95, green: 0.97, blue: 1.0)
                            .ignoresSafeArea()

                        Form {
                            Section {
                                VStack(alignment: .leading, spacing: 12) {
                                    Label(
                                        "When do you want to wake up?",
                                        systemImage: "alarm.fill"
                                    )
                                    .font(.headline)
                                    .foregroundStyle(.blue)

                                    DatePicker(
                                        "Wake-up time",
                                        selection: $wakeUp,
                                        displayedComponents: .hourAndMinute
                                    )
                                    .labelsHidden()
                                    .datePickerStyle(.wheel)
                                    .frame(maxWidth: .infinity)
                                }
                                .padding(.vertical, 8)
                            }

                            Section {
                                VStack(alignment: .leading, spacing: 12) {
                                    Label(
                                        "Desired amount of sleep",
                                        systemImage: "moon.fill"
                                    )
                                    .font(.headline)
                                    .foregroundStyle(.purple)

                                    Stepper(
                                        "\(sleepAmount.formatted()) hours",
                                        value: $sleepAmount,
                                        in: 4...12,
                                        step: 0.25
                                    )
                                    .font(.body)
                                }
                                .padding(.vertical, 8)
                            }

                            Section {
                                VStack(alignment: .leading, spacing: 12) {
                                    Label(
                                        "Daily coffee intake",
                                        systemImage: "cup.and.saucer.fill"
                                    )
                                    .font(.headline)
                                    .foregroundStyle(.brown)

                                    Picker(
                                        "Coffee cups",
                                        selection: $coffeeAmount
                                    ) {
                                        ForEach(1...20, id: \.self) { number in
                                            Text(" \(number) cup\(number == 1 ? "" : "s")")
                                                .tag(number)
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                            }

                            Section {
                                VStack(alignment: .leading, spacing: 12) {
                                    Label(
                                        "Your ideal bedtime",
                                        systemImage: "bed.double.fill"
                                    )
                                    .font(.headline)
                                    .foregroundStyle(.blue)

                                    Text(
                                        bedtime.formatted(
                                            date: .omitted,
                                            time: .shortened
                                        )
                                    )
                                    .font(.system(size: 38, weight: .bold))
                                    .foregroundStyle(.primary)

                                    Text("Sweet dreams! 🌙")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 12)
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                    .navigationTitle("BetterRest")
                    .navigationBarTitleDisplayMode(.large)
                    .onAppear {
                        updateBedtime()
                    }
                    .onChange(of: wakeUp) {
                        updateBedtime()
                    }
                    .onChange(of: sleepAmount) {
                        updateBedtime()
                    }
                    .onChange(of: coffeeAmount) {
                        updateBedtime()
                    }
                }
                .tint(.blue)
            }

    func updateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)

            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(
                wake: Double(hour + minute),
                estimatedSleep: sleepAmount,
                coffee: Double(coffeeAmount)
            )

            bedtime = wakeUp.addingTimeInterval(-prediction.actualSleep)
            
        } catch {
            print("Error calculating bedtime: \(error)")
        }
        
    }
}

#Preview {
    ContentView()
}
