//  1.FrenchPressSettingsView.swift

import SwiftUI

struct FrenchPressSettingsView: View {
    @Binding var cupCount: Int
    @Binding var coffeeAmountManual: Int
    @Binding var waterAmountManual: Int
    @Binding var selectedRatio: Int
    @Binding var grinderSetting: String
    @Binding var brewingTime: TimeInterval
    @Binding var waterTemperature: Int
    let coffeePerCup: Double

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settings: SettingsModel
    @EnvironmentObject var recipeStore: CustomRecipeStore

    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }

    private func timeString(from time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func fahrenheit(from celsius: Int) -> Int {
        return Int(Double(celsius) * 9/5 + 32)
    }

    private var dynamicInstructions: String {
        let brewMinutes = Int(brewingTime / 60)
        if settings.selectedUnit == "Imperial" {
            let coffeeOz = UnitConverter.gramsToOunces(Double(coffeeAmountManual))
            let waterOz  = UnitConverter.millilitersToFluidOunces(Double(waterAmountManual))
            return """
                   French Press’i sıcak su ile ısıtın. Orta kalınlıkta öğütülmüş \
                   \(String(format: "%.2f", coffeeOz)) oz kahveyi koyun. Üzerine \
                   \(String(format: "%.2f", waterOz)) fl oz sıcak suyu yavaş yavaş dökün. \
                   Yaklaşık \(brewMinutes) dakika bekleyin ve ardından pistonu yavaş yavaş aşağı itin.
                   """
        } else {
            return """
                   French Press’i sıcak su ile ısıtın. Orta kalınlıkta öğütülmüş \
                   \(coffeeAmountManual)g kahveyi koyun. Üzerine \
                   \(waterAmountManual)ml sıcak suyu yavaş yavaş dökün. \
                   Yaklaşık \(brewMinutes) dakika bekleyin ve ardından pistonu yavaş yavaş aşağı itin.
                   """
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Bardak")) {
                    Stepper("Bardak: \(cupCount)", value: $cupCount, in: 1...5)
                }

                Section(header: Text("Kahve & Su")) {
                    if settings.selectedUnit == "Imperial" {
                        HStack {
                            Text("Kahve:")
                            Spacer()
                            let coffeeOz = String(format: "%.2f", UnitConverter.gramsToOunces(Double(coffeeAmountManual)))
                            Text("\(coffeeOz) oz")
                        }
                        HStack {
                            Text("Su:")
                            Spacer()
                            let waterOz = String(format: "%.2f", UnitConverter.millilitersToFluidOunces(Double(waterAmountManual)))
                            Text("\(waterOz) fl oz")
                        }
                    } else {
                        HStack {
                            Text("Kahve:")
                            Spacer()
                            Text("\(coffeeAmountManual) g")
                        }
                        HStack {
                            Text("Su:")
                            Spacer()
                            Text("\(waterAmountManual) ml")
                        }
                    }
                }

                Section(header: Text("Oran")) {
                    Picker("Oran", selection: $selectedRatio) {
                        Text("1/13").tag(13)
                        Text("1/14").tag(14)
                        Text("1/15").tag(15)
                        Text("1/16").tag(16)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Su Sıcaklığı")) {
                    HStack {
                        Text("Su Sıcaklığı:")
                        Spacer()
                        Picker("", selection: $waterTemperature) {
                            ForEach(92...95, id: \.self) { temp in
                                if settings.selectedUnit == "Imperial" {
                                    Text("\(fahrenheit(from: temp))°F").tag(temp)
                                } else {
                                    Text("\(temp)°C").tag(temp)
                                }
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }

                Section(header: Text("Öğütücü Ayarı")) {
                    TextField("Öğütücü ayarını giriniz", text: $grinderSetting)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                Section(header: Text("Demleme Süresi")) {
                    VStack(alignment: .leading) {
                        Text("Süre: \(timeString(from: brewingTime))")
                        Slider(value: $brewingTime, in: 60...600, step: 15)
                            .accentColor(.orange)
                    }
                }

                // "Örnek Talimat" bölümü kaldırıldı
            }
            .onAppear {
                if waterTemperature == 0 {
                    waterTemperature = 94
                }
            }
            .onChange(of: cupCount) { newValue in
                switch newValue {
                case 2: coffeeAmountManual = newValue * Int(coffeePerCup) - 5
                case 3: coffeeAmountManual = newValue * Int(coffeePerCup) - 10
                case 4: coffeeAmountManual = newValue * Int(coffeePerCup) - 15
                case 5: coffeeAmountManual = newValue * Int(coffeePerCup) - 15
                default: coffeeAmountManual = newValue * Int(coffeePerCup)
                }
                waterAmountManual = newValue * Int(coffeePerCup) * selectedRatio
                switch newValue {
                case 1: brewingTime = 4 * 60
                case 2: brewingTime = 5 * 60
                case 3: brewingTime = 6 * 60
                case 4: brewingTime = 7 * 60
                case 5: brewingTime = 8 * 60
                default: brewingTime = 4 * 60
                }
            }
            .onChange(of: selectedRatio) { newRatio in
                waterAmountManual = cupCount * Int(coffeePerCup) * newRatio
            }
            .navigationTitle("French Press Ayarları")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                Button("Tamam") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .navigationViewStyle(.stack)  // ← iPad’de split yerine stack modu
    }
}

struct FrenchPressSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        FrenchPressSettingsView(
            cupCount: .constant(1),
            coffeeAmountManual: .constant(15),
            waterAmountManual: .constant(225),
            selectedRatio: .constant(15),
            grinderSetting: .constant("Medium"),
            brewingTime: .constant(240),
            waterTemperature: .constant(94),
            coffeePerCup: 15.0
        )
        .environmentObject(SettingsModel())
        .environmentObject(CustomRecipeStore())
    }
}
