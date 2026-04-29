import SwiftUI

struct ContentView: View {
    enum AppStyle: String, CaseIterable {
        case standard = "标准"
        case cartoon = "卡通"
        case minimal = "极简"
        case ios = "iOS"
    }

    @State private var appStyle: AppStyle = .standard
    @State private var diceCount: Int = 3
    @State private var rollTimes: Int = 1
    @State private var diceValues: [Int] = [1, 2, 3]
    @State private var resultText: String = "暂无结果"
    @State private var history: [String] = []
    @State private var showBlessing = false

    private let version = "0.0.24"
    private let updateDate = "2026年4月29日"

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                header
                stylePicker
                controls
                diceGrid
                Text(resultText).font(.title3.bold()).padding(.vertical, 4)
                Button("▶️ 开始投掷") { rollDice() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                Button("💖 查看祝福") { showBlessing = true }
                    .buttonStyle(.bordered)
                historyList
            }
            .padding()
            .background(background.ignoresSafeArea())
            .onAppear { resetDice() }
            .onChange(of: diceCount) { _ in resetDice() }
            .alert("💖 祝福", isPresented: $showBlessing) {
                Button("收到祝福，继续好运") {}
            } message: {
                Text("亲爱的老婆coco，祝你好运像骰子一样滚滚而来。")
            }
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("🎲 投骰子").font(.largeTitle.bold())
            Text("🔖 版本\(version)   🕒 更新时间：\(updateDate)")
                .font(.caption)
            Text("👤 制作人：王亮   ✉️ wlnet@163.com")
                .font(.caption)
        }
        .multilineTextAlignment(.center)
    }

    private var stylePicker: some View {
        Picker("🎨 界面风格", selection: $appStyle) {
            ForEach(AppStyle.allCases, id: \.self) { style in
                Text(style.rawValue)
            }
        }
        .pickerStyle(.segmented)
    }

    private var controls: some View {
        VStack(spacing: 8) {
            Stepper("🎲 骰子数量：\(diceCount)", value: $diceCount, in: 1...99)
            Stepper("🔁 投掷次数：\(rollTimes)", value: $rollTimes, in: 1...99)
        }
        .font(.subheadline)
    }

    private var diceGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(diceValues.indices, id: \.self) { index in
                    DiceFace(value: diceValues[index], size: diceSize)
                }
            }
            .padding(.vertical, 12)
        }
        .frame(maxHeight: 300)
    }

    private var historyList: some View {
        List(history.prefix(50), id: \.self) { item in
            Text(item).font(.caption)
        }
        .frame(maxHeight: 180)
    }

    private var diceSize: CGFloat {
        if diceCount == 1 { return 54 }
        if diceCount <= 4 { return 52 }
        return max(30, min(56, 320 / CGFloat(max(4, min(diceCount, 10)))))
    }

    private var columns: [GridItem] {
        let available = UIScreen.main.bounds.width - 44
        let count = max(1, min(diceCount, Int(available / (diceSize + 14))))
        return Array(repeating: GridItem(.fixed(diceSize), spacing: 14), count: count)
    }

    private var background: LinearGradient {
        switch appStyle {
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

    private func resetDice() {
        diceValues = (0..<diceCount).map { $0 % 6 + 1 }
    }

    private func rollDice() {
        diceValues = (0..<diceCount).map { _ in Int.random(in: 1...6) }
        let total = diceValues.reduce(0, +) * rollTimes
        resultText = "📊 本次总点数：\(total)"
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
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.18)
                        .stroke(.gray.opacity(0.45), lineWidth: 1.5)
                )
            ForEach(points, id: \.0) { _, point in
                Circle()
                    .fill(.black)
                    .frame(width: size * 0.13, height: size * 0.13)
                    .offset(x: point.x * size * 0.25, y: point.y * size * 0.25)
            }
        }
        .frame(width: size, height: size)
    }

    private var points: [(Int, CGPoint)] {
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
