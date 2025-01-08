import UIKit

class CustomTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        // Настройка внешнего вида текстового поля
        self.borderStyle = .roundedRect
        self.font = UIFont.systemFont(ofSize: 16)
    }
}
