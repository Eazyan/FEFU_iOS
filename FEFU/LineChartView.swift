//import SwiftUI
//
//struct LineChartView: View {
//    var distances: [CGFloat] // Массив расстояний по дням месяца
//    
//    var body: some View {
//        let path = createPath()
//        
//        return path
//            .stroke(Color.orange, lineWidth: 3)
//            .frame(width: CGFloat(distances.count) * 20 + 40, height: 250)
//    }
//    
//    // Разбиваем создание пути на отдельный метод
//    private func createPath() -> Path {
//        var path = Path()
//        
//        guard let first = distances.first else {
//            return path // Возвращаем пустой путь, если нет данных
//        }
//        
//        let chartHeight: CGFloat = 250
//        let padding: CGFloat = 20
//        
//        // Начало пути (первая точка)
//        path.move(to: CGPoint(x: padding, y: chartHeight - first * 10 + padding))
//        
//        // Рисуем линии для всех остальных точек
//        for (index, distance) in distances.enumerated() {
//            let xPosition = CGFloat(index) * 20 + padding
//            let yPosition = chartHeight - distance * 10 + padding
//            path.addLine(to: CGPoint(x: xPosition, y: yPosition))
//        }
//        
//        return path
//    }
//}




import UIKit

class LineChartView: UIView {
    
    var data: [Double] = [] {
        didSet {
            setNeedsDisplay()  // Перерисовываем график при изменении данных
        }
    }

    var labels: [String] = []  // Массив для меток по оси X (например, даты)

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Получаем контекст для рисования
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Белый фон
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)
        
        // Определяем размеры и отступы
        let padding: CGFloat = 20
        let chartWidth = rect.width - padding * 2
        let chartHeight = rect.height - padding * 2
        
        // Нормализуем данные (переводим в проценты относительно высоты графика)
        let maxValue = data.max() ?? 1
        let normalizedData = data.map { ($0 / maxValue) * Double(chartHeight) }
        
        // Создаём путь для линии
        let path = UIBezierPath()
        
        // Начальная точка
        path.move(to: CGPoint(x: padding, y: rect.height - padding - CGFloat(normalizedData[0])))
        
        // Рисуем линии для всех точек
        for (index, value) in normalizedData.enumerated() {
            let xPosition = padding + CGFloat(index) * (chartWidth / CGFloat(data.count - 1))
            let yPosition = rect.height - padding - CGFloat(value)
            path.addLine(to: CGPoint(x: xPosition, y: yPosition))
        }
        
        // Настройка внешнего вида линии
        context.setStrokeColor(UIColor.orange.cgColor)  // Оранжевый цвет
        context.setLineWidth(2)
        context.setLineJoin(.round)
        path.stroke()
        
        // Добавим метки по оси X (даты)
        let labelHeight: CGFloat = 20
        let labelSpacing: CGFloat = chartWidth / CGFloat(data.count - 1)
        for (index, label) in labels.enumerated() {
            let xPosition = padding + CGFloat(index) * labelSpacing
            let labelPoint = CGPoint(x: xPosition, y: rect.height - padding + labelHeight)
            let labelText = UILabel(frame: CGRect(origin: labelPoint, size: CGSize(width: 50, height: labelHeight)))
            labelText.text = label
            labelText.textAlignment = .center
            labelText.font = UIFont.systemFont(ofSize: 10)
            labelText.textColor = .black
            addSubview(labelText)
        }
    }
}
