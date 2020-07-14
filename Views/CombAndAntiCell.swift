import UIKit
class CombAndAntiCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    var combHero : CombHeroInfo? {
        didSet {
            self.nameLabel.text = combHero?.name;
            self.rateLabel.text = "胜率:" + (combHero?.win_rate!)!;
            self.icon.sd_setImage(with: URL.init(string: (combHero?.image)!),placeholderImage: UIImage.init(named: "default_logo"));
        }
    }
    var antiHero : AntiHeroInfo? {
        didSet {
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
