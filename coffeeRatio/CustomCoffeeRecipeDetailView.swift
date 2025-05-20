//  CustomCoffeeRecipeDetailView.swift

import SwiftUI

struct CustomCoffeeRecipeDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settings: SettingsModel
    @ObservedObject var recipeStore: CustomRecipeStore
    let recipe: CustomCoffeeRecipe

    @State private var showingEdit = false
    @State private var showingDeleteAlert = false

    // Countdown timer state
    @State private var remainingTime: TimeInterval = 0
    @State private var timerStarted = false
    @State private var countdownTimer: Timer? = nil

    // Access the latest recipe data
    var currentRecipe: CustomCoffeeRecipe {
        recipeStore.recipes.first { $0.id == recipe.id } ?? recipe
    }

    var body: some View {
        let initialTime = brewTimeInterval(for: currentRecipe)
        let rawTemp = currentRecipe.waterTemperature
        let displayTemp: Int = settings.selectedUnit == "Imperial"
            ? Int(Double(rawTemp) * 9/5 + 32)
            : rawTemp
        let tempUnit = settings.selectedUnit == "Imperial" ? "°F" : "°C"

        // Strip non-numeric characters for conversion
        func numericValue(from str: String) -> Double? {
            let filtered = str.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
            return Double(filtered)
        }

        // Prepare coffee & water display
        let coffeeValRaw = currentRecipe.coffeeAmount
        let waterValRaw  = currentRecipe.waterAmount

        let coffeeDisplay: String = {
            if settings.selectedUnit == "Imperial" {
                if let v = numericValue(from: coffeeValRaw) {
                    return String(format: "%.2f oz", v * 0.035274)
                } else {
                    return coffeeValRaw
                }
            } else {
                if let v = numericValue(from: coffeeValRaw) {
                    return "\(Int(v)) gr"
                } else {
                    return coffeeValRaw
                }
            }
        }()

        let waterDisplay: String = {
            if settings.selectedUnit == "Imperial" {
                if let v = numericValue(from: waterValRaw) {
                    return String(format: "%.2f fl oz", v * 0.033814)
                } else {
                    return waterValRaw
                }
            } else {
                if let v = numericValue(from: waterValRaw) {
                    return "\(Int(v)) ml"
                } else {
                    return waterValRaw
                }
            }
        }()

        return ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Coffee & Water display
                HStack {
                    VStack(alignment: .leading) {
                        Text("Kahve Miktarı").font(.headline)
                        Text(coffeeDisplay)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Su Miktarı").font(.headline)
                        Text(waterDisplay)
                    }
                }

                // Brew Time and Temperature
                HStack {
                    VStack(alignment: .leading) {
                        Text("Demleme Süresi").font(.headline)
                        Text(currentRecipe.brewTime)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Su Sıcaklığı").font(.headline)
                        Text("\(displayTemp)\(tempUnit)")
                    }
                }

                // Grinder setting
                if !currentRecipe.grinderSetting.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Öğütücü").font(.headline)
                        Text(currentRecipe.grinderSetting)
                    }
                }

                // Countdown timer
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Geri Sayım:").font(.title2)
                        Spacer()
                        Text(timeString(from: remainingTime)).font(.title2)
                    }
                    HStack(spacing: 12) {
                        Button {
                            timerStarted ? stopTimer() : startTimer(initial: initialTime)
                        } label: {
                            HStack {
                                Spacer()
                                Text(timerStarted
                                    ? "Durdur"
                                    : (remainingTime < initialTime ? "Devam et" : "Başlat"))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(8)
                            .background(timerStarted ? Color.red : Color.green)
                            .cornerRadius(8)
                        }
                        Button {
                            stopTimer()
                            remainingTime = initialTime
                        } label: {
                            HStack {
                                Spacer()
                                Text("Sıfırla").foregroundColor(.white)
                                Spacer()
                            }
                            .padding(8)
                            .background(Color.gray)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.vertical)

                // User notes
                if !currentRecipe.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notlar").font(.headline)
                        Text(currentRecipe.notes)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                // Delete button
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Sil")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .alert("Bu tarifi silmek istediğinizden emin misiniz?", isPresented: $showingDeleteAlert) {
                    Button("Sil", role: .destructive) {
                        recipeStore.delete(recipe: currentRecipe)
                        presentationMode.wrappedValue.dismiss()
                    }
                    Button("İptal", role: .cancel) { }
                }

            }
            .padding()
        }
        .navigationTitle(currentRecipe.name)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Geri") { presentationMode.wrappedValue.dismiss() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Düzenle") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditCustomRecipeView(recipeStore: recipeStore, recipe: currentRecipe)
                .environmentObject(settings)
        }
        .onAppear { remainingTime = initialTime }
        .onDisappear { stopTimer() }
    }

    // MARK: - Timer Functions

    private func startTimer(initial: TimeInterval) {
        if remainingTime >= initial { remainingTime = initial }
        timerStarted = true
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 { remainingTime -= 1 } else { stopTimer() }
        }
    }

    private func stopTimer() {
        timerStarted = false
        countdownTimer?.invalidate()
        countdownTimer = nil
    }

    // MARK: - Helpers

    private func timeString(from t: TimeInterval) -> String {
        let m = Int(t) / 60, s = Int(t) % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func brewTimeInterval(for recipe: CustomCoffeeRecipe) -> TimeInterval {
        let parts = recipe.brewTime.split(separator: ":")
        if parts.count == 2,
           let m = Int(parts[0]), let s = Int(parts[1]) {
            return TimeInterval(m * 60 + s)
        }
        return 240
    }
}
