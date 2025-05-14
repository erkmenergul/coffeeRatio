//  AddCustomRecipeView.swift

import SwiftUI

struct AddCustomRecipeView: View {
    @Binding var temperature: Int
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var recipeStore: CustomRecipeStore
    @EnvironmentObject var settings: SettingsModel

    @State private var name: String = ""
    @State private var coffeeAmount: String = ""
    @State private var waterAmount: String = ""
    @State private var brewTimeSeconds: Int = 0
    @State private var grinderSetting: String = ""
    @State private var notes: String = ""

    private func timeString(from seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func fahrenheit(from celsius: Int) -> Int {
        return Int(Double(celsius) * 9/5 + 32)
    }

    var body: some View {
        let coffeeUnit = settings.selectedUnit == "Imperial" ? "oz" : "g"
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

                    HStack {
                        Text("Su Sıcaklığı")
                        Spacer()
                        if settings.selectedUnit == "Imperial" {
                            Picker("", selection: $temperature) {
                                ForEach([92, 93, 94, 95], id: \.self) { temp in
                                    Text("\(fahrenheit(from: temp))°F").tag(temp)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        } else {
                            Picker("", selection: $temperature) {
                                ForEach(92...95, id: \.self) { temp in
                                    Text("\(temp)°C").tag(temp)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                }

                Section(header: Text("Öğütücü")) {
                    TextField("Öğütücü ayarı girin", text: $grinderSetting)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                Section(header: Text("Notlar")) {
                    TextEditor(text: $notes)
                        .frame(height: 150)
                }
            }
            .navigationTitle("Yeni Tarif Ekle")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        let brew = timeString(from: brewTimeSeconds)
                        let notesText = notes.trimmingCharacters(in: .whitespacesAndNewlines)
                        let newRecipe = CustomCoffeeRecipe(
                            id: UUID(),
                            name: name,
                            coffeeAmount: "\(coffeeAmount)",
                            waterAmount: "\(waterAmount)",
                            brewTime: brew,
                            notes: notesText,
                            grinderSetting: grinderSetting,
                            waterTemperature: temperature
                        )
                        recipeStore.recipes.append(newRecipe)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(
                        name.isEmpty ||
                        coffeeAmount.isEmpty ||
                        waterAmount.isEmpty
                    )
                }
            }
        }
    }
}

struct AddCustomRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        AddCustomRecipeView(
            temperature: .constant(94),
            recipeStore: CustomRecipeStore()
        )
        .environmentObject(SettingsModel())
    }
}
