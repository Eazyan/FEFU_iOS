// ActivityTableViewCell.swift

import UIKit

class ActivityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Reduce cell width
        let inset: CGFloat = 16
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 8, left: inset, bottom: 8, right: inset))
        
        // Add shadow to cell (optional)
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        contentView.layer.masksToBounds = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure cell state on selection
    }

}
