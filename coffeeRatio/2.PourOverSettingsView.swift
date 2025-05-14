// 2.PourOverSettingsView.swift

//  PourOverSettingsView.swift

import SwiftUI

struct PourOverSettingsView: View {
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

    private func timeString(from time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
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
        tempOptions.reduce(into: [:]) { dict, temp in
            let label = settings.selectedUnit == "Imperial"
                ? "\(Int(Double(temp) * 9/5 + 32))°F"
                : "\(temp)°C"
            dict[temp] = label
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Bardak")) {
                    Stepper("Bardak: \(cupCount)", value: $cupCount, in: 1...5)
                }

                Section(header: Text("Kahve & Su")) {
                    HStack { Text("Kahve:"); Spacer(); Text(coffeeValue) }
                    HStack { Text("Su:");   Spacer(); Text(waterValue) }
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
            .onChange(of: cupCount) { newCount in
                switch newCount {
                case 1:
                    coffeeAmountManual = 15; waterAmountManual = 225; brewingTime = 3 * 60
                case 2:
                    coffeeAmountManual = 25; waterAmountManual = 450; brewingTime = 3 * 60 + 30
                case 3:
                    coffeeAmountManual = 40; waterAmountManual = 675; brewingTime = 5 * 60
                case 4:
                    coffeeAmountManual = 50; waterAmountManual = 900; brewingTime = 6 * 60 + 15
                case 5:
                    coffeeAmountManual = 65; waterAmountManual = 1125; brewingTime = 8 * 60
                default:
                    coffeeAmountManual = Int(coffeePerCup)
                    waterAmountManual = Int(coffeePerCup) * selectedRatio
                    brewingTime = 3 * 60
                }
            }
            .onChange(of: selectedRatio) { newRatio in
                waterAmountManual = cupCount * Int(coffeePerCup) * newRatio
            }
            .navigationTitle("Pour Over Ayarları")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                Button("Tamam") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct PourOverSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        PourOverSettingsView(
            cupCount: .constant(1),
            coffeeAmountManual: .constant(15),
            waterAmountManual: .constant(225),
            selectedRatio: .constant(15),
            grinderSetting: .constant("Medium"),
            brewingTime: .constant(180),
            waterTemperature: .constant(92),
            coffeePerCup: 15.0
        )
        .environmentObject(SettingsModel())
    }
}
