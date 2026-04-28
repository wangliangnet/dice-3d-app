import SwiftUI

struct ContentView: View {
    @State private var diceCount: Int = 1
    @State private var rollTimes: Int = 1
    @State private var result: Int = 0
    @State private var history: [String] = []

    var body: some View {
        VStack(spacing: 20) {
            Text("投骰子 App v0.0.18")
                .font(.title)

            Stepper("骰子数量: \(diceCount)", value: $diceCount, in: 1...99)
            Stepper("投掷次数: \(rollTimes)", value: $rollTimes, in: 1...99)

            Button("开始投掷") {
                rollDice()
            }
            .padding()

            Text("结果: \(result)")
                .font(.largeTitle)

            List(history, id: \.self) { item in
                Text(item)
            }
        }
        .padding()
    }

    func rollDice() {
        var total = 0
        for _ in 0..<rollTimes {
            for _ in 0..<diceCount {
                total += Int.random(in: 1...6)
            }
        }
        result = total
        history.insert("骰子: \(diceCount)，次数: \(rollTimes)，结果: \(total)", at: 0)
        if history.count > 50 { history.removeLast() }
    }
}

#Preview {
    ContentView()
}
