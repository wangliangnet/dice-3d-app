import SwiftUI

struct ContentView: View {
    @State private var dice = 3
    @State private var times = 1
    @State private var result = 0

    var body: some View {
        VStack(spacing:20){
            Text("投骰子 v0.0.19").font(.title)
            Stepper("骰子:\(dice)", value:$dice,in:1...99)
            Stepper("次数:\(times)", value:$times,in:1...99)
            Button("开始投掷"){ roll() }
            Text("结果:\(result)").font(.largeTitle)
        }.padding()
    }

    func roll(){
        var total=0
        for _ in 0..<(dice*times){ total += Int.random(in:1...6)}
        result=total
    }
}
