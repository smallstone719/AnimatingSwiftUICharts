//
//  ContentView.swift
//  AnimatingSwiftUICharts
//
//  Created by Thach Nguyen Trong on 4/6/24.
//

import SwiftUI
import Charts

struct ContentView: View {
    @State private var appDownloads: [Download] = sampleDownloads
    @State private var isAnimated: Bool = false
    @State private var trigger: Bool = false
    @State private var chartType: ChartType = .barMark
    var body: some View {
        NavigationStack {
            List {
                Section("Chart Type") {
                    Picker("", selection: $chartType) {
                        ForEach(ChartType.allCases) { type in
                            Text(type.name)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Demo") {
                    VStack {
                        Chart {
                            ForEach(appDownloads) { download in
                                switch chartType {
                                    /// https://www.swiftyplace.com/blog/swiftcharts-create-charts-and-graphs-in-swiftui
                                case .barMark:
                                    BarMark(x: .value("Month", download.month),
                                            y: .value("Downloads", download.isAnimated ? download.value : 0)
                                    )
                                    .foregroundStyle(by: .value("Month", download.month))
                                    .opacity(download.isAnimated ? 1 : 0)
                                case .lineMark:
                                    LineMark(x: .value("Month", download.month),
                                            y: .value("Downloads", download.isAnimated ? download.value : 0)
                                    )
                                  
                                    .interpolationMethod(.cardinal)
//                                    .symbol(by: .value("Month",  download.month))
//                                    .foregroundStyle(by: .value("Month", download.month))
                                    .opacity(download.isAnimated ? 1 : 0)
                                case .sectorMark:
                                    SectorMark(
                                        angle: .value("Downloads",download.isAnimated ? download.value : 0),
                                        innerRadius: .ratio(0.5),
                                        angularInset: 1.5
                                    )
                                    .foregroundStyle(by: .value("Month", download.month))
                                    .opacity(download.isAnimated ? 1 : 0)
                                }
                            }
                        }
                        .chartYScale(domain: 0...12000)
                        .frame(height: 250)
                        .padding()
                        .background(.background, in: .rect(cornerRadius: 10))
                        
                        //                        Spacer()
                    }
                    .padding(.horizontal, -20)
                }
                //                .padding()
                //                .background(.gray.opacity(0.12))
            }
            .navigationTitle("Animation Chart's")
            .onAppear(perform: animateChart)
            .onChange(of: trigger, initial: false) { oldValue, newValue in
                resetChartAnimation()
                animateChart()
            }
            .onChange(of: chartType, initial: false) { oldValue, newValue in
                resetChartAnimation()
                animateChart()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Trigger") {
                        appDownloads.append(contentsOf: [
                            .init(date: .createDate(1, 2, 2024), value: 4500),
                            .init(date: .createDate(1, 3, 2024), value: 2500),
                            .init(date: .createDate(1, 5, 2024), value: 6500),
                        ])
                        trigger.toggle()
                    }
                }
            }
        }
        
    }
    
    private func animateChart() {
        guard !isAnimated else { return }
        isAnimated = true
        
        $appDownloads.enumerated().forEach { index, element in
            // Limited to a maximun index of 5.
            if index > 5 {
                element.wrappedValue.isAnimated = true
            } else {
                let delay = Double(index) * 0.05
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.smooth) {
                        element.wrappedValue.isAnimated = true
                    }
                }
            }
        }
    }
    
    private func resetChartAnimation() {
        $appDownloads.forEach { download in
            download.wrappedValue.isAnimated = false
        }
        isAnimated = false
    }
}

#Preview {
    ContentView()
}

enum ChartType: String, Identifiable, CaseIterable {
    case barMark, lineMark, sectorMark
    var id: Self {
        return self
    }
    var name: String {
        switch self {
        case .barMark:
            return "Bar"
        case .lineMark:
            return "Line"
        case .sectorMark:
            return "Pie"
        }
    }
}
