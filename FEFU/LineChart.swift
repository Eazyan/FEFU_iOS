////
////  LineChart.swift
////  FEFU
////
////  Created by Антон Лёгкий on 17.01.2025.
////
//
//
//import SwiftUI
//
//struct LineChart: View {
//    var data: [CGFloat] = [0.03, 0.05, 0.08, 0.10]  // Примерные данные
//    
//    var body: some View {
//        Path { path in
//            guard let first = data.first else { return }
//            path.move(to: CGPoint(x: 0, y: 200 - first * 200))
//            
//            for (index, value) in data.enumerated() {
//                path.addLine(to: CGPoint(x: CGFloat(index) * 50, y: 200 - value * 200))
//            }
//        }
//        .stroke(Color.orange, lineWidth: 3)
//        .frame(height: 250)  // Высота графика
//    }
//}
//
//struct ContentView: View {
//    var body: some View {
//        VStack {
//            Text("График активности")
//                .font(.title)
//            LineChart()  // Вставляем наш график
//        }
//        .padding()
//    }
//}
