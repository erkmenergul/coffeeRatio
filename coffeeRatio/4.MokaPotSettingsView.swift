//  4.MokaPotSettingsView.swift

//  MokaPotSettingsView.swift

import SwiftUI

struct MokaPotSettingsView: View {
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

    private var numberFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .none
        return f
    }

    private func timeString(from seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    private func fahrenheit(from celsius: Int) -> Int {
        Int(Double(celsius) * 9/5 + 32)
    }

    private var coffeeValue: String {
        if settings.selectedUnit == "Imperial" {
            let oz = UnitConverter.gramsToOunces(Double(coffeeAmountManual))
            return String(format: "%.2f oz", oz)
        }
        return "\(coffeeAmountManual) gr"
    }
    private var waterValue: String {
        if settings.selectedUnit == "Imperial" {
            let fl = UnitConverter.millilitersToFluidOunces(Double(waterAmountManual))
            return String(format: "%.2f fl oz", fl)
        }
        return "\(waterAmountManual) ml"
    }

    private let tempOptions = [92, 93, 94, 95]
    private var tempLabels: [Int: String] {
        Dictionary(uniqueKeysWithValues: tempOptions.map { temp in
            let label = settings.selectedUnit == "Imperial"
                ? "\(fahrenheit(from: temp))°F"
                : "\(temp)°C"
            return (temp, label)
        })
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Bardak")) {
                    Stepper("Bardak: \(cupCount)", value: $cupCount, in: 1...3)
                }

                Section(header: Text("Kahve & Su")) {
                    HStack { Text("Kahve:"); Spacer(); Text(coffeeValue) }
                    HStack { Text("Su:");    Spacer(); Text(waterValue) }
                }

                Section(header: Text("Oran")) {
                    Picker("Oran", selection: $selectedRatio) {
                        Text("1/10").tag(10)
                        Text("1/11").tag(11)
                        Text("1/12").tag(12)
                        Text("1/13").tag(13)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Su Sıcaklığı")) {
                    HStack {
                        Text("Su Sıcaklığı:"); Spacer()
                        Picker("", selection: $waterTemperature) {
                            ForEach(tempOptions, id: \.self) { temp in
                                Text(tempLabels[temp] ?? "").tag(temp)
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
                    }
                }
            }
            .onAppear {
                if waterTemperature == 0 {
                    waterTemperature = 95
                }
            }
            .onChange(of: cupCount) { count in
                switch count {
                case 1:
                    coffeeAmountManual = 14; waterAmountManual = 150; brewingTime = 4 * 60
                case 2:
                    coffeeAmountManual = 30; waterAmountManual = 310; brewingTime = 5 * 60
                case 3:
                    coffeeAmountManual = 40; waterAmountManual = 450; brewingTime = 6 * 60
                default:
                    break
                }
            }
            .onChange(of: selectedRatio) { ratio in
                waterAmountManual = cupCount * Int(coffeePerCup) * ratio
            }
            .navigationTitle("Moka Pot Ayarları")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                Button("Tamam") { presentationMode.wrappedValue.dismiss() }
            )
        }
    }
}

struct MokaPotSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MokaPotSettingsView(
            cupCount: .constant(1),
            coffeeAmountManual: .constant(14),
            waterAmountManual: .constant(150),
            selectedRatio: .constant(11),
            grinderSetting: .constant("Medium"),
            brewingTime: .constant(4 * 60),
            waterTemperature: .constant(95),
            coffeePerCup: 14.0
        )
        .environmentObject(SettingsModel())
        .environmentObject(CustomRecipeStore())
    }
}
