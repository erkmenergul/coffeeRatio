//  ChronometerView.swift

import SwiftUI

struct ChronometerView: View {
    let initialTime: TimeInterval
    @State private var remainingTime: TimeInterval
    @State private var isRunning = false
    @State private var timer: Timer? = nil

    init(initialTime: TimeInterval) {
        self.initialTime = initialTime
        _remainingTime = State(initialValue: initialTime)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Text(timeString(from: remainingTime))
                .font(.title)
                .monospacedDigit()
                .frame(maxWidth: .infinity, alignment: .center)
            
            HStack(spacing: 20) {
                Button(action: {
                    if isRunning {
                        stopTimer()
                    } else {
                        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                            if remainingTime > 0 {
                                remainingTime -= 1
                            } else {
                                stopTimer()
                            }
                        }
                        isRunning = true
                    }
                }) {
                    Text(isRunning ? "Durdur" : "Başlat")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    stopTimer()
                    remainingTime = initialTime
                }) {
                    Text("Sıfırla")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func timeString(from time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

