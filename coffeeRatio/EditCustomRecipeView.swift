//  EditCustomRecipeView.swift

import SwiftUI

struct EditCustomRecipeView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settings: SettingsModel
    @ObservedObject var recipeStore: CustomRecipeStore
    var recipe: CustomCoffeeRecipe

    @State private var name: String
    @State private var coffeeAmount: String
    @State private var waterAmount: String
    @State private var brewTimeSeconds: Int
    @State private var temperature: Int
    @State private var grinderSetting: String
    @State private var notes: String

    init(recipeStore: CustomRecipeStore, recipe: CustomCoffeeRecipe) {
        self.recipeStore = recipeStore
        self.recipe = recipe
        _name = State(initialValue: recipe.name)
        _coffeeAmount = State(initialValue: recipe.coffeeAmount)
        _waterAmount = State(initialValue: recipe.waterAmount)
        let components = recipe.brewTime.split(separator: ":").map { Int($0) ?? 0 }
        let totalSeconds = (components.first ?? 0) * 60 + (components.count > 1 ? components[1] : 0)
        _brewTimeSeconds = State(initialValue: totalSeconds)
        _temperature = State(initialValue: recipe.waterTemperature)
        _grinderSetting = State(initialValue: recipe.grinderSetting)
        _notes = State(initialValue: recipe.notes)
    }

    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        let coffeeUnit = settings.selectedUnit == "Imperial" ? "oz" : "gr"
        let waterUnit  = settings.selectedUnit == "Imperial" ? "fl oz" : "ml"
        let tempUnit   = settings.selectedUnit == "Imperial" ? "°F" : "°C"

        NavigationView {
            Form {
                Section(header: Text("Tarif Bilgileri")) {
                    TextField("Tarif Adı", text: $name)
                    TextField("Kahve Miktarı (\(coffeeUnit))", text: $coffeeAmount)
                        .keyboardType(.decimalPad)
                    TextField("Su Miktarı (\(waterUnit))", text: $waterAmount)
                        .keyboardType(.decimalPad)
                    Stepper(
                        "Demleme Süresi: \(timeString(from: brewTimeSeconds))",
                        value: $brewTimeSeconds,
                        in: 0...15*60,
                        step: 15
                    )
                }

                Section(header: Text("Su Sıcaklığı")) {
                    HStack {
                        Text("Su Sıcaklığı: \(temperature)\(tempUnit)")
                        Spacer()
                        Picker("", selection: $temperature) {
                            if settings.selectedUnit == "Imperial" {
                                ForEach([92, 93, 94, 95], id: \.self) { t in
                                    Text("\(Int(Double(t) * 9/5 + 32))°F").tag(t)
                                }
                            } else {
                                ForEach(92...95, id: \.self) { t in
                                    Text("\(t)°C").tag(t)
                                }
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }

                Section(header: Text("Öğütücü")) {
                    TextField("Öğütücü Ayarı", text: $grinderSetting)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                Section(header: Text("Notlar")) {
                    TextEditor(text: $notes)
                        .frame(height: 150)
                }
            }
            .navigationTitle("Tarifi Düzenle")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        let brewTimeString = timeString(from: brewTimeSeconds)
                        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
                        let updatedRecipe = CustomCoffeeRecipe(
                            id: recipe.id,
                            name: name,
                            coffeeAmount: coffeeAmount,
                            waterAmount: waterAmount,
                            brewTime: brewTimeString,
                            notes: trimmedNotes,
                            grinderSetting: grinderSetting,
                            waterTemperature: temperature
                        )
                        if let index = recipeStore.recipes.firstIndex(where: { $0.id == recipe.id }) {
                            recipeStore.recipes[index] = updatedRecipe
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty || coffeeAmount.isEmpty || waterAmount.isEmpty)
                }
            }
        }
        .navigationViewStyle(.stack)  // ← iPad’de split yerine stack modu
    }
}

struct EditCustomRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        let store = CustomRecipeStore()
        let sample = CustomCoffeeRecipe(
            id: UUID(),
            name: "Test Tarifi",
            coffeeAmount: "15",
            waterAmount: "225",
            brewTime: "04:00",
            notes: "Örnek not",
            grinderSetting: "Orta",
            waterTemperature: 94
        )
        store.recipes = [sample]
        return EditCustomRecipeView(recipeStore: store, recipe: sample)
            .environmentObject(SettingsModel())
    }
}
