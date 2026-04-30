import SwiftUI

struct ContentView: View {
    enum AppStyle: String, CaseIterable { case standard = "标准", cartoon = "卡通", minimal = "极简", ios = "iOS" }
    @State private var style: AppStyle = .standard
    @State private var diceCount = 3
    @State private var rollTimes = 1
    @State private var dice = [1, 2, 3]
    @State private var result = "📊 暂无结果"
    @State private var history: [String] = []
    @State private var showBlessing = false
    let version = "0.0.24"
    let releaseDate = "2026年4月29日"

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                VStack(spacing: 6) {
                    Text("🎲 投骰子").font(.largeTitle.bold())
                    Text("🔖 版本\(version)   🕒 更新时间：\(releaseDate)").font(.caption)
                    Text("👤 制作人：王亮   ✉️ wlnet@163.com").font(.caption)
                }
                .multilineTextAlignment(.center)

                Picker("🎨 界面风格", selection: $style) {
                    ForEach(AppStyle.allCases, id: \.self) { item in Text(item.rawValue) }
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading) {
                    Stepper("🎲 骰子数量：\(diceCount)", value: $diceCount, in: 1...99)
                    Stepper("🔁 投掷次数：\(rollTimes)", value: $rollTimes, in: 1...99)
                }
                .font(.subheadline)
                .onChange(of: diceCount) { _ in resetDice() }

                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 14) {
                        ForEach(dice.indices, id: \.self) { i in
                            DiceFace(value: dice[i], size: diceSize)
                        }
                    }
                    .padding()
                }

                Text(result).font(.title3.bold()).padding(.vertical, 6)

                Button("▶️ 开始投掷") { roll() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                Button("💖 查看祝福") { showBlessing = true }
                    .buttonStyle(.bordered)

                List(history.prefix(50), id: \.self) { item in
                    Text(item).font(.caption)
                }
                .frame(maxHeight: 180)
            }
            .padding()
            .background(background.ignoresSafeArea())
            .onAppear { resetDice() }
            .alert("💖 祝福", isPresented: $showBlessing) {
                Button("收到祝福，继续好运") {}
            } message: {
                Text("亲爱的老婆coco，祝你好运像骰子一样滚滚而来。")
            }
        }
    }

    var gridColumns: [GridItem] {
        let count = max(1, min(diceCount, Int(UIScreen.main.bounds.width / (diceSize + 14))))
        return Array(repeating: GridItem(.fixed(diceSize), spacing: 14), count: count)
    }

    var diceSize: CGFloat {
        if diceCount == 1 { return 54 }
        return max(30, min(56, 300 / CGFloat(max(3, min(diceCount, 8)))))
    }

    var background: LinearGradient {
        switch style {
        case .standard:
            return LinearGradient(colors: [.blue.opacity(0.08), .white], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .cartoon:
            return LinearGradient(colors: [.yellow.opacity(0.35), .pink.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .minimal:
            return LinearGradient(colors: [.gray.opacity(0.15), .white], startPoint: .top, endPoint: .bottom)
        case .ios:
            return LinearGradient(colors: [Color(.systemGroupedBackground), .blue.opacity(0.08)], startPoint: .top, endPoint: .bottom)
        }
    }

    func resetDice() {
        dice = (0..<diceCount).map { $0 % 6 + 1 }
    }

    func roll() {
        dice = (0..<diceCount).map { _ in Int.random(in: 1...6) }
        let total = dice.reduce(0, +) * rollTimes
        result = "📊 本次总点数：\(total)"
        history.insert("\(Date().formatted())｜\(diceCount)个 × \(rollTimes)次｜\(total)点", at: 0)
    }
}

struct DiceFace: View {
    let value: Int
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.18)
                .fill(.white)
                .overlay(RoundedRectangle(cornerRadius: size * 0.18).stroke(.gray.opacity(0.45), lineWidth: 1.5))
            ForEach(points, id: \.0) { _, point in
                Circle()
                    .fill(.black)
                    .frame(width: size * 0.13, height: size * 0.13)
                    .offset(x: point.x * size * 0.25, y: point.y * size * 0.25)
            }
        }
        .frame(width: size, height: size)
    }

    var points: [(Int, CGPoint)] {
        let a: CGFloat = 1
        switch value {
        case 1: return [(0, .zero)]
        case 2: return [(0, CGPoint(x: -a, y: -a)), (1, CGPoint(x: a, y: a))]
        case 3: return [(0, CGPoint(x: -a, y: -a)), (1, .zero), (2, CGPoint(x: a, y: a))]
        case 4: return [(0, CGPoint(x: -a, y: -a)), (1, CGPoint(x: a, y: -a)), (2, CGPoint(x: -a, y: a)), (3, CGPoint(x: a, y: a))]
        case 5: return [(0, CGPoint(x: -a, y: -a)), (1, CGPoint(x: a, y: -a)), (2, .zero), (3, CGPoint(x: -a, y: a)), (4, CGPoint(x: a, y: a))]
        default: return [(0, CGPoint(x: -a, y: -a)), (1, CGPoint(x: a, y: -a)), (2, CGPoint(x: -a, y: 0)), (3, CGPoint(x: a, y: 0)), (4, CGPoint(x: -a, y: a)), (5, CGPoint(x: a, y: a))]
        }
    }
}
