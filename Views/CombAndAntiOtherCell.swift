import UIKit
class CombAndAntiOtherCell: UITableViewCell {
    var antiHero : AntiHeroInfo? {
        didSet {
            self.nameLabel.text = antiHero?.name;
            let str = (antiHero?.win_rate!)!;
            let val : Double = 100 - (str as NSString).doubleValue
            let disstr = String.init(format: "%.2f", val);
            self.rateLabel.text = "胜率:\(disstr)%";
            self.icon.sd_setImage(with: URL.init(string: (antiHero?.image)!),placeholderImage: UIImage.init(named: "default_logo"));
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
