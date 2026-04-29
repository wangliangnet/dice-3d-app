import SwiftUI

struct ContentView: View {
    @State private var diceCount = 3
    @State private var rollTimes = 1
    @State private var values = [1,2,3]
    @State private var result = "暂无结果"
    @State private var history: [String] = []

    var body: some View {
        VStack(spacing: 14) {
            Text("🎲 投骰子").font(.largeTitle.bold())
            Text("版本0.0.26 · 更新时间：2026年4月29日").font(.caption)
            Picker("界面风格", selection: .constant(0)) {
                Text("标准").tag(0); Text("卡通").tag(1); Text("极简").tag(2); Text("iOS").tag(3)
            }.pickerStyle(.segmented)
            Stepper("骰子数量：\(diceCount)", value: $diceCount, in: 1...99).onChange(of: diceCount) { _ in reset() }
            Stepper("投掷次数：\(rollTimes)", value: $rollTimes, in: 1...99)
            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(values.indices, id: \.self) { i in DiceFace(value: values[i], size: diceSize) }
                }.padding()
            }
            Text(result).font(.title3.bold())
            Button("开始投掷") { roll() }.buttonStyle(.borderedProminent)
            List(history.prefix(50), id: \.self) { Text($0).font(.caption) }
            Text("制作人：王亮 · wlnet@163.com").font(.caption).padding(.top, 4)
        }.padding().onAppear { reset() }
    }
    var diceSize: CGFloat { diceCount == 1 ? 54 : max(30, min(56, 320 / CGFloat(max(4, min(diceCount, 10))))) }
    var columns: [GridItem] { Array(repeating: GridItem(.fixed(diceSize), spacing: 14), count: max(1, min(diceCount, 6))) }
    func reset() { values = (0..<diceCount).map { $0 % 6 + 1 } }
    func roll() { values = (0..<diceCount).map { _ in Int.random(in: 1...6) }; let total = values.reduce(0,+) * rollTimes; result = "总点数：\(total)"; history.insert("\(diceCount)个 × \(rollTimes)次｜\(total)点", at: 0) }
}

struct DiceFace: View {
    let value: Int; let size: CGFloat
    var body: some View { ZStack { RoundedRectangle(cornerRadius: size * 0.18).fill(.white).overlay(RoundedRectangle(cornerRadius: size * 0.18).stroke(.gray, lineWidth: 1)); ForEach(points.indices, id: \.self) { i in Circle().fill(.black).frame(width: size * 0.13, height: size * 0.13).offset(x: points[i].x * size * 0.25, y: points[i].y * size * 0.25) } }.frame(width: size, height: size) }
    var points: [CGPoint] { let a: CGFloat = 1; switch value { case 1: return [.zero]; case 2: return [CGPoint(x:-a,y:-a),CGPoint(x:a,y:a)]; case 3: return [CGPoint(x:-a,y:-a),.zero,CGPoint(x:a,y:a)]; case 4: return [CGPoint(x:-a,y:-a),CGPoint(x:a,y:-a),CGPoint(x:-a,y:a),CGPoint(x:a,y:a)]; case 5: return [CGPoint(x:-a,y:-a),CGPoint(x:a,y:-a),.zero,CGPoint(x:-a,y:a),CGPoint(x:a,y:a)]; default: return [CGPoint(x:-a,y:-a),CGPoint(x:a,y:-a),CGPoint(x:-a,y:0),CGPoint(x:a,y:0),CGPoint(x:-a,y:a),CGPoint(x:a,y:a)] } }
}
